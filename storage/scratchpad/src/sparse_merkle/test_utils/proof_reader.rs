// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::ProofRead;
use arx_crypto::HashValue;
use arx_types::proof::SparseMerkleProofExt;
use std::collections::HashMap;

#[derive(Default)]
pub struct ProofReader(HashMap<HashValue, SparseMerkleProofExt>);

impl ProofReader {
    pub fn new(key_with_proof: Vec<(HashValue, SparseMerkleProofExt)>) -> Self {
        ProofReader(key_with_proof.into_iter().collect())
    }
}

impl ProofRead for ProofReader {
    fn get_proof(&self, key: HashValue) -> Option<&SparseMerkleProofExt> {
        self.0.get(&key)
    }
}
