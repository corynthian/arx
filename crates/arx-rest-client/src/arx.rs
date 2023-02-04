// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use arx_api_types::U64;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct ArxCoin {
    pub value: U64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Balance {
    pub coin: ArxCoin,
}

impl Balance {
    pub fn get(&self) -> u64 {
        *self.coin.value.inner()
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ArxVersion {
    pub major: U64,
}
