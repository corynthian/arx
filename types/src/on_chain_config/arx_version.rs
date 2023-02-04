// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::on_chain_config::OnChainConfig;
use serde::{Deserialize, Serialize};

/// Defines the version of Arx Validator software.
#[derive(Clone, Debug, Deserialize, PartialEq, Eq, PartialOrd, Ord, Serialize)]
pub struct Version {
    pub major: u64,
}

impl OnChainConfig for Version {
    const MODULE_IDENTIFIER: &'static str = "version";
    const TYPE_IDENTIFIER: &'static str = "Version";
}

// NOTE: version number for release 1.2 (inherited from Diem)
// Items gated by this version number include:
//  - the EntryFunction payload type
pub const ARX_VERSION_2: Version = Version { major: 2 };

// NOTE: version number for release 1.3 (inherited from Diem)
// Items gated by this version number include:
//  - Multi-agent transactions
pub const ARX_VERSION_3: Version = Version { major: 3 };

// NOTE: version number for release 1.4 (inherited from Diem)
// Items gated by this version number include:
//  - Conflict-Resistant Sequence Numbers
pub const ARX_VERSION_4: Version = Version { major: 4 };

// Maximum current known version
pub const ARX_MAX_KNOWN_VERSION: Version = ARX_VERSION_4;
