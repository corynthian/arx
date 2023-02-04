// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::account_address::AccountAddress;
pub use move_core_types::language_storage::CORE_CODE_ADDRESS;

// Arx-TODO: Investigate removal of the test root address.

pub fn arx_test_root_address() -> AccountAddress {
    AccountAddress::from_hex_literal("0xA550C18")
        .expect("Parsing valid hex literal should always succeed")
}

pub fn reserved_vm_address() -> AccountAddress {
    AccountAddress::new([0u8; AccountAddress::LENGTH])
}
