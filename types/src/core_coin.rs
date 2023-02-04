// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::account_address::AccountAddress;
use move_core_types::{
    ident_str,
    language_storage::{StructTag, TypeTag},
};
use once_cell::sync::Lazy;

pub static Arx_COIN_TYPE: Lazy<TypeTag> = Lazy::new(|| {
    TypeTag::Struct(Box::new(StructTag {
        address: AccountAddress::ONE,
        module: ident_str!("arx_coin").to_owned(),
        name: ident_str!("ArxCoin").to_owned(),
        type_params: vec![],
    }))
});
