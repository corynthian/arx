// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

use crate::{
    logging::{LogEntry, LogSchema},
    metrics::{increment_counter, start_timer},
    network::PeerMonitoringServiceNetworkEvents,
};
use arx_bounded_executor::BoundedExecutor;
use arx_config::config::PeerMonitoringServiceConfig;
use arx_logger::prelude::*;
use arx_network::{application::storage::PeersAndMetadata, ProtocolId};
use arx_peer_monitoring_service_types::{
    ConnectedPeersResponse, PeerMonitoringServiceError, PeerMonitoringServiceRequest,
    PeerMonitoringServiceResponse, Result, ServerProtocolVersionResponse,
};
use futures::stream::StreamExt;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use thiserror::Error;
use tokio::runtime::Handle;

mod logging;
mod metrics;
pub mod network;

#[cfg(test)]
mod tests;

/// Peer monitoring server constants
pub const PEER_MONITORING_SERVER_VERSION: u64 = 1;

#[derive(Clone, Debug, Deserialize, Error, PartialEq, Eq, Serialize)]
pub enum Error {
    #[error("Invalid request received: {0}")]
    InvalidRequest(String),
    #[error("Unexpected error encountered: {0}")]
    UnexpectedErrorEncountered(String),
}

impl Error {
    /// Returns a summary label for the error type
    fn get_label(&self) -> &'static str {
        match self {
            Error::InvalidRequest(_) => "invalid_request",
            Error::UnexpectedErrorEncountered(_) => "unexpected_error",
        }
    }
}

/// The server-side actor for the peer monitoring service
pub struct PeerMonitoringServiceServer {
    bounded_executor: BoundedExecutor,
    network_requests: PeerMonitoringServiceNetworkEvents,
    peer_metadata: Arc<PeersAndMetadata>,
}

impl PeerMonitoringServiceServer {
    pub fn new(
        config: PeerMonitoringServiceConfig,
        executor: Handle,
        network_requests: PeerMonitoringServiceNetworkEvents,
        peer_metadata: Arc<PeersAndMetadata>,
    ) -> Self {
        let bounded_executor =
            BoundedExecutor::new(config.max_concurrent_requests as usize, executor);

        Self {
            bounded_executor,
            network_requests,
            peer_metadata,
        }
    }

    /// Starts the peer monitoring service server thread
    pub async fn start(mut self) {
        // Handle the service requests
        while let Some(request) = self.network_requests.next().await {
            // Log the request
            let (peer, protocol, request, response_sender) = request;
            debug!(LogSchema::new(LogEntry::ReceivedPeerMonitoringRequest)
                .request(&request)
                .message(&format!(
                    "Received peer monitoring request. Peer: {:?}, protocol: {:?}.",
                    peer, protocol,
                )));

            // All handler methods are currently CPU-bound so we want
            // to spawn on the blocking thread pool.
            let peer_metadata = self.peer_metadata.clone();
            self.bounded_executor
                .spawn_blocking(move || {
                    let response = Handler::new(peer_metadata).call(protocol, request);
                    log_monitoring_service_response(&response);
                    response_sender.send(response);
                })
                .await;
        }
    }
}

/// The `Handler` is the "pure" inbound request handler. It contains all the
/// necessary context and state needed to construct a response to an inbound
/// request. We usually clone/create a new handler for every request.
#[derive(Clone)]
pub struct Handler {
    peers_and_metadata: Arc<PeersAndMetadata>,
}

impl Handler {
    pub fn new(peers_and_metadata: Arc<PeersAndMetadata>) -> Self {
        Self { peers_and_metadata }
    }

    pub fn call(
        &self,
        protocol: ProtocolId,
        request: PeerMonitoringServiceRequest,
    ) -> Result<PeerMonitoringServiceResponse> {
        // Update the request count
        increment_counter(
            &metrics::PEER_MONITORING_REQUESTS_RECEIVED,
            protocol,
            request.get_label(),
        );

        // Time the request processing (the timer will stop when it's dropped)
        let _timer = start_timer(
            &metrics::PEER_MONITORING_REQUEST_PROCESSING_LATENCY,
            protocol,
            request.get_label(),
        );

        // Process the request
        let response = match &request {
            PeerMonitoringServiceRequest::GetConnectedPeers => self.get_connected_peers(),
            PeerMonitoringServiceRequest::GetDepthFromValidators => {
                self.get_depth_from_validators()
            },
            PeerMonitoringServiceRequest::GetKnownPeers => self.get_known_peers(),
            PeerMonitoringServiceRequest::GetServerProtocolVersion => {
                self.get_server_protocol_version()
            },
            PeerMonitoringServiceRequest::GetValidatorsAndVFNs => self.get_validators_and_vfns(),
            PeerMonitoringServiceRequest::Ping => self.handle_ping(),
        };

        // Process the response and handle any errors
        match response {
            Err(error) => {
                // Log the error and update the counters
                increment_counter(
                    &metrics::PEER_MONITORING_ERRORS_ENCOUNTERED,
                    protocol,
                    error.get_label(),
                );
                error!(LogSchema::new(LogEntry::PeerMonitoringServiceError)
                    .error(&error)
                    .request(&request));

                // Return an appropriate response to the client
                match error {
                    Error::InvalidRequest(error) => {
                        Err(PeerMonitoringServiceError::InvalidRequest(error))
                    },
                    error => Err(PeerMonitoringServiceError::InternalError(error.to_string())),
                }
            },
            Ok(response) => {
                // The request was successful
                increment_counter(
                    &metrics::PEER_MONITORING_RESPONSES_SENT,
                    protocol,
                    response.get_label(),
                );
                Ok(response)
            },
        }
    }

    fn get_connected_peers(&self) -> Result<PeerMonitoringServiceResponse, Error> {
        let connected_peers = self
            .peers_and_metadata
            .get_connected_peers_and_metadata()
            .map_err(|error| Error::UnexpectedErrorEncountered(format!("{:?}", error)))?;
        Ok(PeerMonitoringServiceResponse::ConnectedPeers(
            ConnectedPeersResponse { connected_peers },
        ))
    }

    fn get_depth_from_validators(&self) -> Result<PeerMonitoringServiceResponse, Error> {
        Err(Error::InvalidRequest(
            "get_depth_from_validators() is currently unsupported!".into(),
        ))
    }

    fn get_known_peers(&self) -> Result<PeerMonitoringServiceResponse, Error> {
        Err(Error::InvalidRequest(
            "get_known_peers() is currently unsupported!".into(),
        ))
    }

    fn get_server_protocol_version(&self) -> Result<PeerMonitoringServiceResponse, Error> {
        Ok(PeerMonitoringServiceResponse::ServerProtocolVersion(
            ServerProtocolVersionResponse {
                version: PEER_MONITORING_SERVER_VERSION,
            },
        ))
    }

    fn get_validators_and_vfns(&self) -> Result<PeerMonitoringServiceResponse, Error> {
        Err(Error::InvalidRequest(
            "get_validators_and_vfns() is currently unsupported!".into(),
        ))
    }

    fn handle_ping(&self) -> Result<PeerMonitoringServiceResponse, Error> {
        Err(Error::InvalidRequest(
            "handle_ping() is currently unsupported!".into(),
        ))
    }
}

/// Logs the response sent by the monitoring service for a request
fn log_monitoring_service_response(
    monitoring_service_response: &Result<PeerMonitoringServiceResponse, PeerMonitoringServiceError>,
) {
    match monitoring_service_response {
        Ok(response) => {
            let response = format!("{:?}", response);
            debug!(LogSchema::new(LogEntry::SentPeerMonitoringResponse).response(&response));
        },
        Err(error) => {
            let error = format!("{:?}", error);
            debug!(LogSchema::new(LogEntry::SentPeerMonitoringResponse).response(&error));
        },
    };
}
