// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

#![allow(unused_imports)]

pub use crate::arx_transaction_builder::*;
use arx_types::{account_address::AccountAddress, transaction::TransactionPayload};

pub fn arx_coin_transfer(to: AccountAddress, amount: u64) -> TransactionPayload {
    coin_transfer(
        arx_types::arx_coin::ARX_COIN_TYPE.clone(),
        to,
        amount,
    )
}
