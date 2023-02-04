/// The chain id distinguishes between different chains (e.g., testnet and the main network).
/// One important role is to prevent transactions intended for one chain from being executed on another.
/// This code provides a container for storing a chain id and functions to initialize and get it.
module arx::chain_id {
    use arx::system_addresses;

    friend arx::genesis;

    struct ChainId has key {
        id: u8
    }

    /// Only called during genesis.
    /// Publish the chain ID `id` of this instance under the SystemAddresses address
    public(friend) fun initialize(arx: &signer, id: u8) {
        system_addresses::assert_arx(arx);
        move_to(arx, ChainId { id })
    }

    /// Return the chain ID of this instance.
    public fun get(): u8 acquires ChainId {
        borrow_global<ChainId>(@arx).id
    }

    #[test_only]
    public fun initialize_for_test(arx: &signer, id: u8) {
        initialize(arx, id);
    }

    #[test(arx = @0x1)]
    fun test_get(arx: &signer) acquires ChainId {
        initialize_for_test(arx, 1u8);
        assert!(get() == 1u8, 1);
    }
}
