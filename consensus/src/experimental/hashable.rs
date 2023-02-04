// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use arx_crypto::HashValue;

pub trait Hashable {
    fn hash(&self) -> HashValue;
}
