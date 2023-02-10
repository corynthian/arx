// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use arx_config::{config::IdentityBlob, keys::ConfigKey};
use arx_crypto::{
    bls12381,
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    x25519, PrivateKey,
};
use arx_keygen::KeyGen;
use arx_types::{account_address::AccountAddress, transaction::authenticator::AuthenticationKey};
use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize)]
pub struct DominusPrivateIdentity {
    pub account_address: AccountAddress,
    pub account_private_key: Ed25519PrivateKey,
}

#[derive(Deserialize, Serialize)]
pub struct DominusPublicIdentity {
    pub account_address: AccountAddress,
    pub account_public_key: Ed25519PublicKey,
}

/// Type for serializing private keys file
#[derive(Deserialize, Serialize)]
pub struct PrivateIdentity {
    pub account_address: AccountAddress,
    pub account_private_key: Ed25519PrivateKey,
    pub consensus_private_key: bls12381::PrivateKey,
    pub full_node_network_private_key: x25519::PrivateKey,
    pub validator_network_private_key: x25519::PrivateKey,
}

/// Type for serializing public keys file
#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct PublicIdentity {
    pub account_address: AccountAddress,
    pub account_public_key: Ed25519PublicKey,
    pub consensus_public_key: Option<bls12381::PublicKey>,
    pub consensus_proof_of_possession: Option<bls12381::ProofOfPossession>,
    pub full_node_network_public_key: Option<x25519::PublicKey>,
    pub validator_network_public_key: Option<x25519::PublicKey>,
}

#[derive(Deserialize, Serialize)]
pub struct DominusIdentity {
    pub private_identity: DominusPrivateIdentity,
    pub public_identity: DominusPublicIdentity,
}

#[derive(Deserialize, Serialize)]
pub struct ValidatorIdentity {
    pub validator_identity: IdentityBlob,
    pub vfn_identity: IdentityBlob,
    pub private_identity: PrivateIdentity,
    pub public_identity: PublicIdentity,
}

/// Generates objects used for a user in genesis
pub fn generate_key_objects(
    keygen: &mut KeyGen,
) -> anyhow::Result<(DominusIdentity, ValidatorIdentity)> {
    let dominus_key = ConfigKey::new(keygen.generate_ed25519_private_key());
    let account_key = ConfigKey::new(keygen.generate_ed25519_private_key());
    let consensus_key = ConfigKey::new(keygen.generate_bls12381_private_key());
    let validator_network_key = ConfigKey::new(keygen.generate_x25519_private_key()?);
    let full_node_network_key = ConfigKey::new(keygen.generate_x25519_private_key()?);

    let dominus_address = AuthenticationKey::ed25519(&dominus_key.public_key()).derived_address();
    let account_address = AuthenticationKey::ed25519(&account_key.public_key()).derived_address();

    let dominus_private_identity = DominusPrivateIdentity {
        account_address: dominus_address,
        account_private_key: dominus_key.private_key(),
    };
    let dominus_public_identity = DominusPublicIdentity {
        account_address: dominus_address,
        account_public_key: dominus_key.public_key(),
    };

    // Build these for use later as node identity
    let validator_blob = IdentityBlob {
        account_address: Some(account_address),
        account_private_key: Some(account_key.private_key()),
        consensus_private_key: Some(consensus_key.private_key()),
        network_private_key: validator_network_key.private_key(),
    };
    let vfn_blob = IdentityBlob {
        account_address: Some(account_address),
        account_private_key: None,
        consensus_private_key: None,
        network_private_key: full_node_network_key.private_key(),
    };

    let private_identity = PrivateIdentity {
        account_address,
        account_private_key: account_key.private_key(),
        consensus_private_key: consensus_key.private_key(),
        full_node_network_private_key: full_node_network_key.private_key(),
        validator_network_private_key: validator_network_key.private_key(),
    };

    let public_identity = PublicIdentity {
        account_address,
        account_public_key: account_key.public_key(),
        consensus_public_key: Some(private_identity.consensus_private_key.public_key()),
        consensus_proof_of_possession: Some(bls12381::ProofOfPossession::create(
            &private_identity.consensus_private_key,
        )),
        full_node_network_public_key: Some(full_node_network_key.public_key()),
        validator_network_public_key: Some(validator_network_key.public_key()),
    };

    Ok((
	DominusIdentity {
	    private_identity: dominus_private_identity,
	    public_identity: dominus_public_identity,
	},
	ValidatorIdentity {
	    validator_identity: validator_blob,
	    vfn_identity: vfn_blob,
	    private_identity,
	    public_identity,
	}
    ))
}
