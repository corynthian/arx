// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::{account_address::AccountAddress, event::EventHandle};
use serde::{Deserialize, Serialize};

// Arx-TODO: Review for Arx

#[derive(Debug, Serialize, Deserialize)]
pub struct VestingAdminStore {
    pub vesting_contracts: Vec<AccountAddress>,
    nonce: u64,
    create_events: EventHandle,
}
