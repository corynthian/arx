module arx::archon {
    use arx::arx_coin::ArxCoin;
    use arx::solaris;

    use std::bls12381::{Self, proof_of_possession_from_bytes};
    use std::error;
    use std::option;
    use std::signer;

    friend arx::senatus;

    struct Archon has key, copy, store, drop {
	owner_address: address,
	consensus_pubkey: vector<u8>,
	network_addresses: vector<u8>,
	fullnode_addresses: vector<u8>,
	validator_index: u64,
	lux_power: u64,
    }

    const EINVALID_PUBLIC_KEY: u64 = 1;

    /// Initializes a network archon with an initial allocation (if non-zero).
    public entry fun initialize(
	account: &signer,
	consensus_pubkey: vector<u8>,
	proof_of_possession: vector<u8>,
	network_addresses: vector<u8>,
	fullnode_addresses: vector<u8>,
	initial_allocation: u64,
    ) {
	// Checks the public key has a valid proof-of-possession to prevent rogue-key attacks.
        let pubkey_from_pop = &mut bls12381::public_key_from_bytes_with_pop(
            consensus_pubkey,
            &proof_of_possession_from_bytes(proof_of_possession)
        );
        assert!(option::is_some(pubkey_from_pop), error::invalid_argument(EINVALID_PUBLIC_KEY));

	// Initialize the ArxCoin allocation.
	if (initial_allocation > 0) {
	    solaris::initialize_allocation<ArxCoin>(account, initial_allocation);
	};

        move_to(account, Archon {
	    owner_address: signer::address_of(account),
            consensus_pubkey,
            network_addresses,
            fullnode_addresses,
            validator_index: 0,
	    lux_power: 0,
        });
    }

    /// Get the archons account address.
    public fun get_owner_address(archon: &Archon): address {
	archon.owner_address
    }
}
