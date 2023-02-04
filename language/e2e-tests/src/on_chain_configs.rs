// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::{account::Account, executor::FakeExecutor};
use arx_cached_packages::arx;
use arx_types::{account_config::CORE_CODE_ADDRESS, on_chain_config::Version};
use arx_vm::ArxVM;

pub fn set_arx_version(executor: &mut FakeExecutor, version: Version) {
    let account = Account::new_genesis_account(CORE_CODE_ADDRESS);
    let txn = account
        .transaction()
        .payload(arx::version_set_version(version.major))
        .sequence_number(0)
        .sign();
    executor.new_block();
    executor.execute_and_apply(txn);

    let new_vm = ArxVM::new(executor.get_state_view());
    assert_eq!(new_vm.internals().version().unwrap(), version);
}
