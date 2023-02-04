// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use anyhow::anyhow;
use arx_config::{config::NodeConfig, utils::get_genesis_txn};
use arx_db::ArxDB;
use arx_executor::db_bootstrapper::maybe_bootstrap;
use arx_logger::{debug, info};
use arx_storage_interface::{DbReader, DbReaderWriter};
use arx_types::waypoint::Waypoint;
use arx_vm::ArxVM;
use std::{fs, net::SocketAddr, path::Path, sync::Arc, time::Instant};
use tokio::runtime::Runtime;

#[cfg(not(feature = "consensus-only-perf-test"))]
pub(crate) fn bootstrap_db(
    arx_db: ArxDB,
    backup_service_address: SocketAddr,
) -> (Arc<ArxDB>, DbReaderWriter, Option<Runtime>) {
    use arx_backup_service::start_backup_service;

    let (arx_db, db_rw) = DbReaderWriter::wrap(arx_db);
    let db_backup_service = start_backup_service(backup_service_address, arx_db.clone());
    (arx_db, db_rw, Some(db_backup_service))
}

/// In consensus-only mode, return a in-memory based [FakeArxDB] and
/// do not run the backup service.
#[cfg(feature = "consensus-only-perf-test")]
pub(crate) fn bootstrap_db(
    arx_db: ArxDB,
    _backup_service_address: SocketAddr,
) -> (
    Arc<arx_db::fake_arxdb::FakeArxDB>,
    DbReaderWriter,
    Option<Runtime>,
) {
    use arx_db::fake_arxdb::FakeArxDB;

    let (arx_db, db_rw) = DbReaderWriter::wrap(FakeArxDB::new(arx_db));
    (arx_db, db_rw, None)
}

/// Creates a RocksDb checkpoint for the consensus_db, state_sync_db,
/// ledger_db and state_merkle_db and saves it to the checkpoint_path.
/// Also, changes the working directory to run the node on the new path,
/// so that the existing data won't change. For now this is a test-only feature.
fn create_rocksdb_checkpoint_and_change_working_dir(
    node_config: &mut NodeConfig,
    working_dir: impl AsRef<Path>,
) {
    // Update the source and checkpoint directories
    let source_dir = node_config.storage.dir();
    node_config.set_data_dir(working_dir.as_ref().to_path_buf());
    let checkpoint_dir = node_config.storage.dir();
    assert!(source_dir != checkpoint_dir);

    // Create rocksdb checkpoint directory
    fs::create_dir_all(&checkpoint_dir).unwrap();

    // Open the database and create a checkpoint
    ArxDB::create_checkpoint(&source_dir, &checkpoint_dir)
        .expect("ArxDB checkpoint creation failed.");

    // Create a consensus db checkpoint
    arx_consensus::create_checkpoint(&source_dir, &checkpoint_dir)
        .expect("ConsensusDB checkpoint creation failed.");

    // Create a state sync db checkpoint
    let state_sync_db =
        arx_state_sync_driver::metadata_storage::PersistentMetadataStorage::new(&source_dir);
    state_sync_db
        .create_checkpoint(&checkpoint_dir)
        .expect("StateSyncDB checkpoint creation failed.");
}

/// Creates any rocksdb checkpoints, opens the storage database,
/// starts the backup service, handles genesis initialization and returns
/// the various handles.
pub fn initialize_database_and_checkpoints(
    node_config: &mut NodeConfig,
) -> anyhow::Result<(Arc<dyn DbReader>, DbReaderWriter, Option<Runtime>, Waypoint)> {
    // If required, create RocksDB checkpoints and change the working directory.
    // This is test-only.
    if let Some(working_dir) = node_config.base.working_dir.clone() {
        create_rocksdb_checkpoint_and_change_working_dir(node_config, working_dir);
    }

    // Open the database
    let instant = Instant::now();
    let arx_db = ArxDB::open(
        &node_config.storage.dir(),
        false, /* readonly */
        node_config.storage.storage_pruner_config,
        node_config.storage.rocksdb_configs,
        node_config.storage.enable_indexer,
        node_config.storage.buffered_state_target_items,
        node_config.storage.max_num_nodes_per_lru_cache_shard,
    )
    .map_err(|err| anyhow!("DB failed to open {}", err))?;
    let (arx_db, db_rw, backup_service) =
        bootstrap_db(arx_db, node_config.storage.backup_service_address);

    // TODO: handle non-genesis waypoints for state sync!
    // If there's a genesis txn and waypoint, commit it if the result matches.
    let genesis_waypoint = node_config.base.waypoint.genesis_waypoint();
    if let Some(genesis) = get_genesis_txn(node_config) {
        maybe_bootstrap::<ArxVM>(&db_rw, genesis, genesis_waypoint)
            .map_err(|err| anyhow!("DB failed to bootstrap {}", err))?;
    } else {
        info!("Genesis txn not provided! This is fine only if you don't expect to apply it. Otherwise, the config is incorrect!");
    }

    // Log the duration to open storage
    debug!(
        "Storage service started in {} ms",
        instant.elapsed().as_millis()
    );

    Ok((arx_db, db_rw, backup_service, genesis_waypoint))
}
