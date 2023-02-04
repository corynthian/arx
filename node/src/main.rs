// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

use arx_node::{utils::ERROR_MSG_BAD_FEATURE_FLAGS, ArxNodeArgs};
use clap::Parser;

#[cfg(unix)]
#[global_allocator]
static ALLOC: jemallocator::Jemalloc = jemallocator::Jemalloc;

fn main() {
    // Check that we are not including any Move test natives
    arx_vm::natives::assert_no_test_natives(ERROR_MSG_BAD_FEATURE_FLAGS);

    // Start the node
    ArxNodeArgs::parse().run()
}
