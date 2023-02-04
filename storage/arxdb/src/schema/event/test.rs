// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use super::*;
use arx_schemadb::{schema::fuzzing::assert_encode_decode, test_no_panic_decoding};
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_encode_decode(
        version in any::<Version>(),
        index in any::<u64>(),
        event in any::<ContractEvent>(),
    ) {
        assert_encode_decode::<EventSchema>(&(version, index), &event);
    }
}

test_no_panic_decoding!(EventSchema);
