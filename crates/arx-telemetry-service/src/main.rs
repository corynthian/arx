#![forbid(unsafe_code)]

// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use arx_telemetry_service::ArxTelemetryServiceArgs;
use clap::Parser;

#[tokio::main]
async fn main() {
    arx_logger::Logger::new().init();
    ArxTelemetryServiceArgs::parse().run().await;
}
