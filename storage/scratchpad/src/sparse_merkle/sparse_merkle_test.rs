// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use super::*;
use crate::test_utils::{
    proof_reader::ProofReader,
    proptest_helpers::{arb_smt_correctness_case, test_smt_correctness_impl},
};
use arx_crypto::{
    hash::{CryptoHash, TestOnlyHash, SPARSE_MERKLE_PLACEHOLDER_HASH},
    HashValue,
};
use arx_types::{
    proof::{definition::NodeInProof, SparseMerkleLeafNode, SparseMerkleProofExt},
    state_store::state_value::StateValue,
};
use once_cell::sync::Lazy;
use proptest::prelude::*;
use std::collections::VecDeque;

fn update_byte(original_key: &HashValue, n: usize, byte: u8) -> HashValue {
    let mut key = original_key.to_vec();
    key[n] = byte;
    HashValue::from_slice(&key).unwrap()
}

fn hash_internal(left_child: HashValue, right_child: HashValue) -> HashValue {
    arx_types::proof::SparseMerkleInternalNode::new(left_child, right_child).hash()
}

fn hash_leaf(key: HashValue, value_hash: HashValue) -> HashValue {
    SparseMerkleLeafNode::new(key, value_hash).hash()
}

type SparseMerkleTree = super::SparseMerkleTree<StateValue>;
type SubTree = super::SubTree<StateValue>;

#[test]
fn test_replace_in_mem_leaf() {
    let key = b"hello".test_only_hash();
    let value_hash = b"world".test_only_hash();
    let leaf = SubTree::new_leaf_with_value_hash(key, value_hash, 0 /* generation */);
    let smt = SparseMerkleTree::new_with_root(leaf);

    let new_value: StateValue = vec![1, 2, 3].into();
    let root_hash = hash_leaf(key, new_value.hash());
    let updated = smt
        .batch_update(vec![(key, Some(&new_value))], &ProofReader::default())
        .unwrap();
    assert_eq!(updated.root_hash(), root_hash);
    let updated = updated
        .batch_update(vec![(key, None)], &ProofReader::default())
        .unwrap();
    assert_eq!(updated.root_hash(), *SPARSE_MERKLE_PLACEHOLDER_HASH);
}

#[test]
fn test_split_in_mem_leaf() {
    let key1 = HashValue::from_slice([0; 32]).unwrap();
    let value1_hash = b"hello".test_only_hash();
    let leaf1 = SubTree::new_leaf_with_value_hash(key1, value1_hash, 0 /* generation */);
    let old_root_hash = leaf1.hash();
    let smt = SparseMerkleTree::new_with_root(leaf1);

    let key2 = HashValue::from_slice([0xFF; 32]).unwrap();
    let value2: StateValue = vec![1, 2, 3].into();

    let root_hash = hash_internal(hash_leaf(key1, value1_hash), hash_leaf(key2, value2.hash()));
    let updated = smt
        .batch_update(vec![(key2, Some(&value2))], &ProofReader::default())
        .unwrap();
    assert_eq!(updated.root_hash(), root_hash);
    let updated = updated
        .batch_update(vec![(key2, None)], &ProofReader::default())
        .unwrap();
    assert_eq!(updated.root_hash(), old_root_hash);
}

#[test]
fn test_insert_at_in_mem_empty() {
    let key1 = HashValue::from_slice([0; 32]).unwrap();
    let value1_hash = b"hello".test_only_hash();
    let key2 = update_byte(&key1, 0, 0b01000000);
    let value2_hash = b"world".test_only_hash();

    let key3 = update_byte(&key1, 0, 0b10000000);
    let value3: StateValue = vec![1, 2, 3].into();

    let internal = SubTree::new_internal(
        SubTree::new_leaf_with_value_hash(key1, value1_hash, 0 /* generation */),
        SubTree::new_leaf_with_value_hash(key2, value2_hash, 0 /* generation */),
        0, /* generation */
    );
    let internal_hash = internal.hash();
    let root = SubTree::new_internal(internal, SubTree::new_empty(), 0 /* generation */);
    let smt = SparseMerkleTree::new_with_root(root);

    let root_hash = hash_internal(internal_hash, hash_leaf(key3, value3.hash()));
    let updated = smt
        .batch_update(vec![(key3, Some(&value3))], &ProofReader::default())
        .unwrap();
    assert_eq!(updated.root_hash(), root_hash);
}

#[test]
fn test_replace_persisted_leaf() {
    let key = b"hello".test_only_hash();
    let value_hash = b"world".test_only_hash();
    let leaf = SparseMerkleLeafNode::new(key, value_hash);
    let proof = SparseMerkleProofExt::new(Some(leaf), Vec::new());
    let proof_reader = ProofReader::new(vec![(key, proof)]);

    let smt = SparseMerkleTree::new_test(leaf.hash());
    let new_value: StateValue = vec![1, 2, 3].into();
    let root_hash = hash_leaf(key, new_value.hash());
    let updated = smt
        .batch_update(vec![(key, Some(&new_value))], &proof_reader)
        .unwrap();
    assert_eq!(updated.root_hash(), root_hash);
}

#[test]
fn test_delete_persisted_leaf() {
    let key = b"hello".test_only_hash();
    let value_hash = b"world".test_only_hash();
    let leaf = SparseMerkleLeafNode::new(key, value_hash);
    let proof = SparseMerkleProofExt::new(Some(leaf), Vec::new());
    let proof_reader = ProofReader::new(vec![(key, proof)]);

    let smt = SparseMerkleTree::new_test(leaf.hash());
    let updated = smt.batch_update(vec![(key, None)], &proof_reader).unwrap();
    assert_eq!(updated.root_hash(), *SPARSE_MERKLE_PLACEHOLDER_HASH);
}

#[test]
fn test_split_persisted_leaf_and_then_delete() {
    let key1 = HashValue::from_slice([0; 32]).unwrap();
    let value_hash1 = b"hello".test_only_hash();
    let leaf1 = SparseMerkleLeafNode::new(key1, value_hash1);

    let smt = SparseMerkleTree::new_test(leaf1.hash());

    let key2 = HashValue::from_slice([0xFF; 32]).unwrap();
    let value2: StateValue = vec![1, 2, 3].into();
    let proof = SparseMerkleProofExt::new(Some(leaf1), Vec::new());
    let proof_reader = ProofReader::new(vec![(key2, proof)]);

    let leaf2_hash = hash_leaf(key2, value2.hash());
    let root_hash = hash_internal(leaf1.hash(), leaf2_hash);
    let updated = smt
        .batch_update(vec![(key2, Some(&value2))], &proof_reader)
        .unwrap();
    assert_eq!(updated.root_hash(), root_hash);
    let updated = updated
        .batch_update(vec![(key1, None)], &proof_reader)
        .unwrap();
    assert_eq!(updated.root_hash(), leaf2_hash);
}

#[test]
fn test_insert_at_persisted_empty() {
    let key1 = HashValue::from_slice([0; 32]).unwrap();
    let value1_hash = b"hello".test_only_hash();
    let key2 = update_byte(&key1, 0, 0b01000000);
    let value2_hash = b"world".test_only_hash();

    let key3 = update_byte(&key1, 0, 0b10000000);
    let value3: StateValue = vec![1, 2, 3].into();

    let sibling_hash = hash_internal(hash_leaf(key1, value1_hash), hash_leaf(key2, value2_hash));
    let proof = SparseMerkleProofExt::new(None, vec![NodeInProof::Other(sibling_hash)]);
    let proof_reader = ProofReader::new(vec![(key3, proof)]);
    let old_root_hash = hash_internal(sibling_hash, *SPARSE_MERKLE_PLACEHOLDER_HASH);
    let smt = SparseMerkleTree::new_test(old_root_hash);

    let root_hash = hash_internal(sibling_hash, hash_leaf(key3, value3.hash()));
    let updated = smt
        .batch_update(vec![(key3, Some(&value3))], &proof_reader)
        .unwrap();
    assert_eq!(updated.root_hash(), root_hash);
}

#[test]
fn test_update_256_siblings_in_proof() {
    //                   root
    //                  /    \
    //                 o      placeholder
    //                / \
    //               o   placeholder
    //              / \
    //             .   placeholder
    //             .
    //             . (256 levels)
    //             o
    //            / \
    //        key1   key2
    let key1 = HashValue::new([0; HashValue::LENGTH]);
    let key2 = {
        let mut buf = key1.to_vec();
        *buf.last_mut().unwrap() |= 1;
        HashValue::from_slice(&buf).unwrap()
    };

    let value1 = StateValue::from(String::from("test_val1").into_bytes());
    let value2 = StateValue::from(String::from("test_val2").into_bytes());
    let value1_hash = value1.hash();
    let value2_hash = value2.hash();
    let leaf1 = SparseMerkleLeafNode::new(key1, value1_hash);
    let leaf2 = SparseMerkleLeafNode::new(key2, value2_hash);

    let mut siblings: Vec<_> =
        std::iter::repeat(NodeInProof::Other(*SPARSE_MERKLE_PLACEHOLDER_HASH))
            .take(255)
            .collect();
    siblings.push(leaf2.into());
    siblings.reverse();
    let proof_of_key1 = SparseMerkleProofExt::new(Some(leaf1), siblings.clone());

    let old_root_hash = siblings
        .iter()
        .fold(leaf1.hash(), |previous_hash, node_in_proof| {
            hash_internal(previous_hash, node_in_proof.hash())
        });
    assert!(proof_of_key1
        .verify(old_root_hash, key1, Some(&value1))
        .is_ok());

    let new_value1 = StateValue::from(String::from("test_val1111").into_bytes());
    let proof_reader = ProofReader::new(vec![(key1, proof_of_key1)]);
    let smt = SparseMerkleTree::new_test(old_root_hash);
    let new_smt = smt
        .batch_update(vec![(key1, Some(&new_value1))], &proof_reader)
        .unwrap();

    let new_value1_hash = new_value1.hash();
    let new_leaf1_hash = hash_leaf(key1, new_value1_hash);
    let new_root_hash = siblings
        .iter()
        .fold(new_leaf1_hash, |previous_hash, node_in_proof| {
            hash_internal(previous_hash, node_in_proof.hash())
        });
    assert_eq!(new_smt.root_hash(), new_root_hash);

    assert_eq!(
        new_smt.get(key1),
        StateStoreStatus::ExistsInScratchPad(new_value1)
    );
    assert_eq!(new_smt.get(key2), StateStoreStatus::ExistsInDB);
}

#[test]
fn test_new_unknown() {
    let root_hash = HashValue::new([1; HashValue::LENGTH]);
    let smt = SparseMerkleTree::new_test(root_hash);
    assert!(smt.root_weak().is_unknown());
    assert_eq!(smt.root_hash(), root_hash);
}

#[test]
fn test_new_empty() {
    let root_hash = *SPARSE_MERKLE_PLACEHOLDER_HASH;
    let smt = SparseMerkleTree::new_test(root_hash);
    assert!(smt.root_weak().is_empty());
    assert_eq!(smt.root_hash(), root_hash);
}

#[test]
fn test_update() {
    // Before the update, the tree was:
    //             root
    //            /    \
    //           y      key3
    //          / \
    //         x   placeholder
    //        / \
    //    key1   key2
    let key1 = b"aaaaa".test_only_hash();
    let key2 = b"bb".test_only_hash();
    let key3 = b"cccc".test_only_hash();
    assert_eq!(key1[0], 0b0000_0100);
    assert_eq!(key2[0], 0b0010_0100);
    assert_eq!(key3[0], 0b1110_0111);
    let value1 = StateValue::from(String::from("test_val1").into_bytes());
    let value2 = StateValue::from(String::from("test_val2").into_bytes());
    let value3 = StateValue::from(String::from("test_val3").into_bytes());
    let value1_hash = value1.hash();
    let value2_hash = value2.hash();
    let value3_hash = value3.hash();

    // A new key at the "placeholder" position.
    let key4 = b"d".test_only_hash();
    assert_eq!(key4[0], 0b0100_1100);
    let value4 = StateValue::from(String::from("test_val4").into_bytes());
    // Create a proof for this new key.
    let leaf1 = SparseMerkleLeafNode::new(key1, value1_hash);
    let leaf2 = SparseMerkleLeafNode::new(key2, value2_hash);
    let leaf3 = SparseMerkleLeafNode::new(key3, value3_hash);
    let x_hash = hash_internal(leaf1.hash(), leaf2.hash());
    let y_hash = hash_internal(x_hash, *SPARSE_MERKLE_PLACEHOLDER_HASH);
    let old_root_hash = hash_internal(y_hash, leaf3.hash());
    let proof = SparseMerkleProofExt::new(None, vec![
        NodeInProof::Other(x_hash),
        NodeInProof::Leaf(leaf3),
    ]);
    assert!(proof
        .verify::<StateValue>(old_root_hash, key4, None)
        .is_ok());

    // Create the old tree and update the tree with new value and proof.
    let proof_reader = ProofReader::new(vec![(key4, proof)]);
    let smt1 = SparseMerkleTree::new_test(old_root_hash)
        .batch_update(vec![(key4, Some(&value4))], &proof_reader)
        .unwrap();

    // Now smt1 should look like this:
    //             root
    //            /    \
    //           y      key3 (unknown)
    //          / \
    //         x   key4
    assert_eq!(smt1.get(key1), StateStoreStatus::Unknown);
    assert_eq!(smt1.get(key2), StateStoreStatus::Unknown);
    assert_eq!(smt1.get(key3), StateStoreStatus::ExistsInDB);
    assert_eq!(
        smt1.get(key4),
        StateStoreStatus::ExistsInScratchPad(value4.clone())
    );

    let non_existing_key = b"foo".test_only_hash();
    assert_eq!(non_existing_key[0], 0b0111_0110);
    assert_eq!(smt1.get(non_existing_key), StateStoreStatus::DoesNotExist);

    // Verify root hash.
    let value4_hash = value4.hash();
    let leaf4_hash = hash_leaf(key4, value4_hash);
    let y_hash = hash_internal(x_hash, leaf4_hash);
    let root_hash = hash_internal(y_hash, leaf3.hash());
    assert_eq!(smt1.root_hash(), root_hash);

    // Verify oldest ancestor
    assert!(Arc::ptr_eq(&smt1.get_oldest_ancestor().inner, &smt1.inner));

    // Next, we are going to delete key1. Create a proof for key1.
    let proof = SparseMerkleProofExt::new(Some(leaf1), vec![
        leaf2.into(),
        (*SPARSE_MERKLE_PLACEHOLDER_HASH).into(),
        leaf3.into(),
    ]);
    assert!(proof.verify(old_root_hash, key1, Some(&value1)).is_ok());

    let proof_reader = ProofReader::new(vec![(key1, proof)]);
    let smt2 = smt1
        .batch_update(vec![(key1, None)], &proof_reader)
        .unwrap();

    // smt2 looks like:
    //                root
    //               /    \
    //              y      key3 (indb, weak)
    //             / \
    //    key2(indb)  key4 (weak data)
    assert_eq!(smt2.get(key1), StateStoreStatus::DoesNotExist,);
    assert_eq!(smt2.get(key2), StateStoreStatus::ExistsInDB);
    assert_eq!(smt2.get(key3), StateStoreStatus::ExistsInDB);
    assert_eq!(smt2.get(key4), StateStoreStatus::ExistsInScratchPad(value4));

    // Verify root hash.
    let y_hash = hash_internal(leaf2.hash(), leaf4_hash);
    let root_hash = hash_internal(y_hash, leaf3.hash());
    assert_eq!(smt2.root_hash(), root_hash);

    // Verify oldest ancestor
    assert_eq_pointee(&smt2.get_oldest_ancestor(), &smt1);

    // We now try to create another branch on top of smt1.
    let value4 = StateValue::from(String::from("test_val4444").into_bytes());

    // key4 already exists in the tree.
    let proof_reader = ProofReader::default();
    let smt22 = smt1
        .batch_update(vec![(key4, Some(&value4))], &proof_reader)
        .unwrap();

    // smt22 is like:
    //             root
    //            /    \
    //           y'      key3 (indb, weak)
    //          / \
    // (weak) x   key4
    assert_eq!(smt22.get(key2), StateStoreStatus::Unknown);
    assert_eq!(smt22.get(key3), StateStoreStatus::ExistsInDB);
    assert_eq!(
        smt22.get(key4),
        StateStoreStatus::ExistsInScratchPad(value4.clone())
    );

    // Verify oldest ancestor
    assert_eq_pointee(&smt22.get_oldest_ancestor(), &smt1);

    // Now prune smt1.
    drop(smt1);

    // Verify oldest ancestor
    assert_eq_pointee(&smt2.get_oldest_ancestor(), &smt2);
    assert_eq_pointee(&smt22.get_oldest_ancestor(), &smt22);

    // For smt2, no key should be available since smt2 was constructed by deleting key1.
    assert_eq!(smt2.get(key1), StateStoreStatus::DoesNotExist);
    assert_eq!(smt2.get(key2), StateStoreStatus::ExistsInDB);
    assert_eq!(smt2.get(key3), StateStoreStatus::ExistsInDB);
    assert_eq!(smt2.get(key4), StateStoreStatus::ExistsInDB);

    // For smt22, only key4 should be available since smt22 was constructed by updating smt1 with
    // key4.
    assert_eq!(smt22.get(key1), StateStoreStatus::Unknown);
    assert_eq!(smt22.get(key2), StateStoreStatus::Unknown);
    assert_eq!(smt22.get(key3), StateStoreStatus::ExistsInDB);
    assert_eq!(
        smt22.get(key4),
        StateStoreStatus::ExistsInScratchPad(value4)
    );
}

static KEY: Lazy<HashValue> = Lazy::new(|| b"aaaaa".test_only_hash());
static VALUE: Lazy<StateValue> =
    Lazy::new(|| StateValue::from(String::from("test_val").into_bytes()));
static LEAF: Lazy<SparseMerkleLeafNode> =
    Lazy::new(|| SparseMerkleLeafNode::new(*KEY, VALUE.hash()));
static PROOF_READER: Lazy<ProofReader> = Lazy::new(|| {
    let proof = SparseMerkleProofExt::new(Some(*LEAF), vec![]);
    ProofReader::new(vec![(*KEY, proof)])
});

fn update(smt: &SparseMerkleTree) -> SparseMerkleTree {
    smt.batch_update(vec![(*KEY, Some(&VALUE))], &*PROOF_READER)
        .unwrap()
}

#[test]
fn test_get_oldest_ancestor() {
    // smt0 - smt00 - smt000 - smt0000 - smt00000
    //              \
    //              |\ smt001 - smt0010 - smt00100
    //              |        \
    //              |          smt0011 - smt00110
    //              |                  \
    //              |                    smt00111
    //              \
    //                smt002

    let smt0 = SparseMerkleTree::new_test(LEAF.hash());
    let smt00 = update(&smt0);
    let smt000 = update(&smt00);
    let smt0000 = update(&smt000);
    let smt00000 = update(&smt0000);
    let smt001 = update(&smt00);
    let smt0010 = update(&smt001);
    let smt00100 = update(&smt0010);
    let smt0011 = update(&smt001);
    let smt00110 = update(&smt0011);
    let smt00111 = update(&smt0011);
    let smt002 = update(&smt00);

    assert_eq_pointee(&smt0.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt00.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt000.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt0000.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt00000.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt001.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt0010.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt00100.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt0011.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt00110.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt00111.get_oldest_ancestor(), &smt0);
    assert_eq_pointee(&smt002.get_oldest_ancestor(), &smt0);

    drop(smt0);
    assert_eq_pointee(&smt00.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt000.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt0000.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt00000.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt001.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt0010.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt00100.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt0011.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt00110.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt00111.get_oldest_ancestor(), &smt00);
    assert_eq_pointee(&smt002.get_oldest_ancestor(), &smt00);

    drop(smt00);
    assert_eq_pointee(&smt000.get_oldest_ancestor(), &smt000);
    assert_eq_pointee(&smt0000.get_oldest_ancestor(), &smt000);
    assert_eq_pointee(&smt00000.get_oldest_ancestor(), &smt000);
    assert_eq_pointee(&smt001.get_oldest_ancestor(), &smt001);
    assert_eq_pointee(&smt0010.get_oldest_ancestor(), &smt001);
    assert_eq_pointee(&smt00100.get_oldest_ancestor(), &smt001);
    assert_eq_pointee(&smt0011.get_oldest_ancestor(), &smt001);
    assert_eq_pointee(&smt00110.get_oldest_ancestor(), &smt001);
    assert_eq_pointee(&smt00111.get_oldest_ancestor(), &smt001);
    assert_eq_pointee(&smt002.get_oldest_ancestor(), &smt002);

    drop(smt001);
    assert_eq_pointee(&smt000.get_oldest_ancestor(), &smt000);
    assert_eq_pointee(&smt0000.get_oldest_ancestor(), &smt000);
    assert_eq_pointee(&smt00000.get_oldest_ancestor(), &smt000);
    assert_eq_pointee(&smt0010.get_oldest_ancestor(), &smt0010);
    assert_eq_pointee(&smt00100.get_oldest_ancestor(), &smt0010);
    assert_eq_pointee(&smt0011.get_oldest_ancestor(), &smt0011);
    assert_eq_pointee(&smt00110.get_oldest_ancestor(), &smt0011);
    assert_eq_pointee(&smt00111.get_oldest_ancestor(), &smt0011);
    assert_eq_pointee(&smt002.get_oldest_ancestor(), &smt002);
    drop(smt000);
    assert_eq_pointee(&smt0000.get_oldest_ancestor(), &smt0000);
    assert_eq_pointee(&smt00000.get_oldest_ancestor(), &smt0000);

    drop(smt0000);
    assert_eq_pointee(&smt00000.get_oldest_ancestor(), &smt00000);
    drop(smt0010);
    assert_eq_pointee(&smt00100.get_oldest_ancestor(), &smt00100);
    drop(smt0011);
    assert_eq_pointee(&smt00110.get_oldest_ancestor(), &smt00110);
    assert_eq_pointee(&smt00111.get_oldest_ancestor(), &smt00111);
}

fn assert_eq_pointee(left: &SparseMerkleTree, right: &SparseMerkleTree) {
    assert!(Arc::ptr_eq(&left.inner, &right.inner,))
}

/// update smt from multiple threads, creating branches, trying to explore edge cases around
/// branching and dropping
#[test]
fn test_multithread_branching() {
    let t1 = SparseMerkleTree::new_test(LEAF.hash());
    let q = Arc::new(Mutex::new(VecDeque::from(vec![t1])));

    let work = |q: &Arc<Mutex<VecDeque<SparseMerkleTree>>>| {
        let q = q.clone();
        move || {
            for _ in 0..10000 {
                let new = update(q.lock().back().unwrap());

                let _maybe_drop = {
                    let mut q_locked = q.lock();
                    if q_locked.len() > 1 {
                        q_locked.pop_front()
                    } else {
                        None
                    }
                };

                q.lock().push_back(new);
            }
        }
    };

    (0..3)
        .map(|_| std::thread::spawn(work(&q)))
        .collect::<Vec<_>>()
        .into_iter()
        .for_each(|t| t.join().unwrap())
}

#[test]
fn test_multithread_get_oldest_ancestor() {
    let current_tree = Arc::new(Mutex::new(SparseMerkleTree::new_test(LEAF.hash())));

    let update_fn = || {
        let current_tree = current_tree.clone();
        move || {
            for _ in 0..100000 {
                let t = current_tree.lock().clone();
                *current_tree.lock() = update(&t);
            }
        }
    };
    let get_ancestor_fn = || {
        let current_tree = current_tree.clone();
        move || {
            let t = current_tree.lock().clone();
            let mut tree_pair = VecDeque::from(vec![t.clone(), t]);
            for _ in 0..100000 {
                assert!(tree_pair[0]
                    .get_oldest_ancestor()
                    .is_the_same(&tree_pair[1].get_oldest_ancestor()));
                tree_pair.pop_front();
                tree_pair.push_back(current_tree.lock().clone());
            }
        }
    };
    let update = std::thread::spawn(update_fn());
    let gets: Vec<_> = (0..3)
        .map(|_| std::thread::spawn(get_ancestor_fn()))
        .collect();
    update.join().unwrap();
    for t in gets {
        t.join().unwrap();
    }
}

#[test]
fn test_drop() {
    let proof_reader = ProofReader::default();
    let root_smt = SparseMerkleTree::new_test(*SPARSE_MERKLE_PLACEHOLDER_HASH);
    let mut smt = root_smt.clone();
    for _ in 0..100000 {
        smt = smt
            .batch_update(
                vec![(
                    HashValue::zero(),
                    Some(&StateValue::from(String::from("test_val").into_bytes())),
                )],
                &proof_reader,
            )
            .unwrap()
    }

    // root_smt with a long chain of descendants being dropped here. It's a stack overflow if a
    // manual iterative `Drop` implementation is not in place.
    drop(root_smt)
}

proptest! {
    #[test]
    fn test_correctness( input in arb_smt_correctness_case() ) {
        test_smt_correctness_impl(input)
    }
}
