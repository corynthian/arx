// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use serde::{Deserialize, Serialize};

// Arx-TODO: Modify for tower (?)

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct ValidatorPerformance {
    pub successful_proposals: u64,
    pub failed_proposals: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct ValidatorPerformances {
    pub validators: Vec<ValidatorPerformance>,
}
