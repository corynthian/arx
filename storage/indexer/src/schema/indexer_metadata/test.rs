// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use super::*;
use arx_schemadb::{schema::fuzzing::assert_encode_decode, test_no_panic_decoding};
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_encode_decode(
        tag in any::<MetadataKey>(),
        metadata in any::<MetadataValue>(),
    ) {
        assert_encode_decode::<IndexerMetadataSchema>(&tag, &metadata);
    }
}

test_no_panic_decoding!(IndexerMetadataSchema);
