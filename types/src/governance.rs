// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::account_address::AccountAddress;
use serde::{Deserialize, Serialize};

// Arx-TODO: May need to be re-worked

#[derive(Debug, Serialize, Deserialize)]
pub struct VotingRecords {
    pub votes: AccountAddress,
}
