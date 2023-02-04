// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

//! The official Rust SDK for Arx.
//!
//! ## Modules
//!
//! This SDK provides all the necessary components for building on top of the Arx Blockchain. Some of the important modules are:
//!
//! * `crypto` - Types used for signing and verifying
//! * `move_types` - Includes types used when interacting with the Move VM
//! * `rest_client` - The Arx API Client, used for sending requests to the Arx Blockchain.
//! * `transaction_builder` - Includes helpers for constructing transactions
//! * `types` - Includes types for Arx on-chain data structures
//!
//! ## Example
//!
//! Here is a simple example to show how to create two accounts and do a P2p transfer on testnet:
//! todo(davidiw) bring back example using rest
//!

pub use bcs;

pub mod coin_client;

pub mod crypto {
    pub use arx_crypto::*;
}

pub mod move_types {
    pub use move_core_types::*;
}

pub mod rest_client {
    pub use arx_rest_client::*;
}

pub mod transaction_builder;

pub mod types;
