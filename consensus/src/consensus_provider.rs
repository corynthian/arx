// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::{
    counters,
    epoch_manager::EpochManager,
    network::NetworkTask,
    network_interface::{ConsensusMsg, ConsensusNetworkClient},
    persistent_liveness_storage::StorageWriteProxy,
    state_computer::ExecutionProxy,
    txn_notifier::MempoolNotifier,
    util::time_service::ClockTimeService,
};
use arx_config::config::NodeConfig;
use arx_consensus_notifications::ConsensusNotificationSender;
use arx_event_notifications::ReconfigNotificationListener;
use arx_executor::block_executor::BlockExecutor;
use arx_logger::prelude::*;
use arx_mempool::QuorumStoreRequest;
use arx_network::application::interface::{NetworkClient, NetworkServiceEvents};
use arx_storage_interface::DbReaderWriter;
use arx_types::transaction::Transaction;
use arx_vm::ArxVM;
use futures::channel::mpsc;
use std::sync::Arc;
use tokio::runtime::Runtime;

/// Helper function to start consensus based on configuration and return the runtime
pub fn start_consensus(
    node_config: &NodeConfig,
    network_client: NetworkClient<ConsensusMsg>,
    network_service_events: NetworkServiceEvents<ConsensusMsg>,
    state_sync_notifier: Arc<dyn ConsensusNotificationSender>,
    consensus_to_mempool_sender: mpsc::Sender<QuorumStoreRequest>,
    arx_db: DbReaderWriter,
    reconfig_events: ReconfigNotificationListener,
) -> Runtime {
    let runtime = arx_tokio_runtime::spawn_named_runtime("consensus".into(), None);
    let storage = Arc::new(StorageWriteProxy::new(node_config, arx_db.reader.clone()));
    let txn_notifier = Arc::new(MempoolNotifier::new(
        consensus_to_mempool_sender.clone(),
        node_config.consensus.mempool_executed_txn_timeout_ms,
    ));

    let state_computer = Arc::new(ExecutionProxy::new(
        Arc::new(BlockExecutor::<ArxVM, Transaction>::new(arx_db)),
        txn_notifier,
        state_sync_notifier,
        runtime.handle(),
    ));

    let time_service = Arc::new(ClockTimeService::new(runtime.handle().clone()));

    let (timeout_sender, timeout_receiver) =
        arx_channel::new(1_024, &counters::PENDING_ROUND_TIMEOUTS);
    let (self_sender, self_receiver) = arx_channel::new(1_024, &counters::PENDING_SELF_MESSAGES);

    let consensus_network_client = ConsensusNetworkClient::new(network_client);
    let epoch_mgr = EpochManager::new(
        node_config,
        time_service,
        self_sender,
        consensus_network_client,
        timeout_sender,
        consensus_to_mempool_sender,
        state_computer,
        storage,
        reconfig_events,
    );

    let (network_task, network_receiver) = NetworkTask::new(network_service_events, self_receiver);

    runtime.spawn(network_task.start());
    runtime.spawn(epoch_mgr.start(timeout_receiver, network_receiver));

    debug!("Consensus started.");
    runtime
}
