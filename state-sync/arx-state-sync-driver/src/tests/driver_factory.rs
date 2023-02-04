// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::{driver_factory::DriverFactory, metadata_storage::PersistentMetadataStorage};
use arx_config::{
    config::{
        RocksdbConfigs, BUFFERED_STATE_TARGET_ITEMS, DEFAULT_MAX_NUM_NODES_PER_LRU_CACHE_SHARD,
        NO_OP_STORAGE_PRUNER_CONFIG,
    },
    utils::get_genesis_txn,
};
use arx_consensus_notifications::new_consensus_notifier_listener_pair;
use arx_data_client::arxnet::ArxNetDataClient;
use arx_data_streaming_service::streaming_client::new_streaming_service_client_listener_pair;
use arx_db::ArxDB;
use arx_event_notifications::EventSubscriptionService;
use arx_executor::chunk_executor::ChunkExecutor;
use arx_executor_test_helpers::bootstrap_genesis;
use arx_genesis::test_utils::test_config;
use arx_infallible::RwLock;
use arx_mempool_notifications::new_mempool_notifier_listener_pair;
use arx_network::application::{interface::NetworkClient, storage::PeersAndMetadata};
use arx_storage_interface::DbReaderWriter;
use arx_storage_service_client::StorageServiceClient;
use arx_temppath::TempPath;
use arx_time_service::TimeService;
use arx_types::on_chain_config::ON_CHAIN_CONFIG_REGISTRY;
use arx_vm::ArxVM;
use futures::{FutureExt, StreamExt};
use std::{collections::HashMap, sync::Arc};

#[test]
fn test_new_initialized_configs() {
    // Create a test database
    let tmp_dir = TempPath::new();
    let db = ArxDB::open(
        &tmp_dir,
        false,
        NO_OP_STORAGE_PRUNER_CONFIG,
        RocksdbConfigs::default(),
        false,
        BUFFERED_STATE_TARGET_ITEMS,
        DEFAULT_MAX_NUM_NODES_PER_LRU_CACHE_SHARD,
    )
    .unwrap();
    let (_, db_rw) = DbReaderWriter::wrap(db);

    // Bootstrap the database
    let (node_config, _) = test_config();
    bootstrap_genesis::<ArxVM>(&db_rw, get_genesis_txn(&node_config).unwrap()).unwrap();

    // Create mempool and consensus notifiers
    let (mempool_notifier, _) = new_mempool_notifier_listener_pair();
    let (_, consensus_listener) = new_consensus_notifier_listener_pair(0);

    // Create the event subscription service and a reconfig subscriber
    let mut event_subscription_service = EventSubscriptionService::new(
        ON_CHAIN_CONFIG_REGISTRY,
        Arc::new(RwLock::new(db_rw.clone())),
    );
    let mut reconfiguration_subscriber = event_subscription_service
        .subscribe_to_reconfigurations()
        .unwrap();

    // Create a test streaming service client
    let (streaming_service_client, _) = new_streaming_service_client_listener_pair();

    // Create a test arx data client
    let network_client = StorageServiceClient::new(NetworkClient::new(
        vec![],
        vec![],
        HashMap::new(),
        PeersAndMetadata::new(&[]),
    ));
    let (arx_data_client, _) = ArxNetDataClient::new(
        node_config.state_sync.arx_data_client,
        node_config.base.clone(),
        node_config.state_sync.storage_service,
        TimeService::mock(),
        network_client,
        None,
    );

    // Create the state sync driver factory
    let chunk_executor = Arc::new(ChunkExecutor::<ArxVM>::new(db_rw.clone()));
    let metadata_storage = PersistentMetadataStorage::new(tmp_dir.path());
    let _ = DriverFactory::create_and_spawn_driver(
        true,
        &node_config,
        node_config.base.waypoint.waypoint(),
        db_rw,
        chunk_executor,
        mempool_notifier,
        metadata_storage,
        consensus_listener,
        event_subscription_service,
        arx_data_client,
        streaming_service_client,
        TimeService::mock(),
    );

    // Verify the initial configs were notified
    assert!(reconfiguration_subscriber
        .select_next_some()
        .now_or_never()
        .is_some());
}
