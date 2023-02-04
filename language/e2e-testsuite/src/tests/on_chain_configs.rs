// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use arx_cached_packages::arx;
use arx_language_e2e_tests::{common_transactions::peer_to_peer_txn, executor::FakeExecutor};
use arx_types::{
    account_config::CORE_CODE_ADDRESS, on_chain_config::Version, transaction::TransactionStatus,
};
use arx_vm::ArxVM;

#[test]
fn initial_arx_version() {
    let mut executor = FakeExecutor::from_head_genesis();
    let vm = ArxVM::new(executor.get_state_view());
    let version = arx_types::on_chain_config::ARX_MAX_KNOWN_VERSION;

    assert_eq!(vm.internals().version().unwrap(), version,);

    let txn = executor
        .new_account_at(CORE_CODE_ADDRESS)
        .transaction()
        .payload(arx::version_set_version(version.major + 1))
        .sequence_number(0)
        .sign();
    executor.new_block();
    executor.execute_and_apply(txn);

    let new_vm = ArxVM::new(executor.get_state_view());
    assert_eq!(new_vm.internals().version().unwrap(), Version {
        major: version.major + 1
    });
}

#[test]
fn drop_txn_after_reconfiguration() {
    let mut executor = FakeExecutor::from_head_genesis();
    let vm = ArxVM::new(executor.get_state_view());
    let version = arx_types::on_chain_config::ARX_MAX_KNOWN_VERSION;

    assert_eq!(vm.internals().version().unwrap(), version);

    let txn = executor
        .new_account_at(CORE_CODE_ADDRESS)
        .transaction()
        .payload(arx::version_set_version(version.major + 1))
        .sequence_number(0)
        .sign();
    executor.new_block();

    let sender = executor.create_raw_account_data(1_000_000, 10);
    let receiver = executor.create_raw_account_data(100_000, 10);
    let txn2 = peer_to_peer_txn(sender.account(), receiver.account(), 11, 1000);

    let mut output = executor.execute_block(vec![txn, txn2]).unwrap();
    assert_eq!(output.pop().unwrap().status(), &TransactionStatus::Retry)
}
