// Copyright (c) Diem Core Contributors
// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use arx_api::context::Context;
use arx_config::config::NodeConfig;
use arx_mempool::mocks::MockSharedMempool;
use arx_storage_interface::mock::MockDbReaderWriter;
use arx_types::chain_id::ChainId;
use std::sync::Arc;

// This is necessary for building the API with how the code is structured currently.
pub fn get_fake_context() -> Context {
    let mempool = MockSharedMempool::new();
    Context::new(
        ChainId::test(),
        Arc::new(MockDbReaderWriter),
        mempool.ac_client,
        NodeConfig::default(),
    )
}
