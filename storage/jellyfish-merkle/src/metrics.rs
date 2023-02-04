// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use arx_metrics_core::{register_int_counter, register_int_gauge, IntCounter, IntGauge};
use once_cell::sync::Lazy;

pub static ARX_JELLYFISH_LEAF_ENCODED_BYTES: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!(
        "arx_jellyfish_leaf_encoded_bytes",
        "Arx jellyfish leaf encoded bytes in total"
    )
    .unwrap()
});

pub static ARX_JELLYFISH_INTERNAL_ENCODED_BYTES: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!(
        "arx_jellyfish_internal_encoded_bytes",
        "Arx jellyfish total internal nodes encoded in bytes"
    )
    .unwrap()
});

pub static ARX_JELLYFISH_LEAF_COUNT: Lazy<IntGauge> = Lazy::new(|| {
    register_int_gauge!(
        "arx_jellyfish_leaf_count",
        "Total number of leaves in the latest JMT."
    )
    .unwrap()
});

pub static ARX_JELLYFISH_LEAF_DELETION_COUNT: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!(
        "arx_jellyfish_leaf_deletion_count",
        "The number of deletions happened in JMT."
    )
    .unwrap()
});
