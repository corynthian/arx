// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

// Arx-TODO: Questionable renamings ... Investigate effect of changing these.

// pub use move_core_types::vm_status::known_locations::{
//     CORE_ACCOUNT_MODULE, CORE_ACCOUNT_MODULE_IDENTIFIER,
//     DIEM_ACCOUNT_MODULE as Arx_ACCOUNT_MODULE,
//     DIEM_ACCOUNT_MODULE_IDENTIFIER as Arx_ACCOUNT_MODULE_IDENTIFIER,
// };

use move_core_types::{
    ident_str, identifier::IdentStr, language_storage::{ModuleId, CORE_CODE_ADDRESS},
};
use once_cell::sync::Lazy;

pub const CORE_ACCOUNT_MODULE_IDENTIFIER: &IdentStr = ident_str!("account");
pub static CORE_ACCOUNT_MODULE: Lazy<ModuleId> =
    Lazy::new(|| ModuleId::new(CORE_CODE_ADDRESS, CORE_ACCOUNT_MODULE_IDENTIFIER.to_owned()));

pub const ARX_ACCOUNT_MODULE_IDENTIFIER: &IdentStr = ident_str!("arx_account");
pub static ARX_ACCOUNT_MODULE: Lazy<ModuleId> =
    Lazy::new(|| ModuleId::new(CORE_CODE_ADDRESS, ARX_ACCOUNT_MODULE_IDENTIFIER.to_owned()));

