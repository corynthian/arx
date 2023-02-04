/// This module provides foundations to create aggregators. Currently only
/// Open Libra (0x1) can create them, so this module helps to wrap
/// the constructor of `Aggregator` struct so that only a system account
/// can initialize one. In the future, this might change and aggregators
/// can be enabled for the public.
module arx::aggregator_factory {
    use std::error;
    use std::aggregator::Aggregator;
    use std::table::{Self, Table};

    use arx::system_addresses;

    friend arx::genesis;
    friend arx::optional_aggregator;

    /// Aggregator factory is not published yet.
    const EAGGREGATOR_FACTORY_NOT_FOUND: u64 = 1;

    /// Creates new aggregators. Used to control the numbers of aggregators in the
    /// system and who can create them. At the moment, only Open Libra (0x1)
    /// account can.
    struct AggregatorFactory has key {
        phantom_table: Table<address, u128>,
    }

    /// Creates a new factory for aggregators. Can only be called during genesis.
    public(friend) fun initialize_aggregator_factory(arx: &signer) {
        system_addresses::assert_arx(arx);
        let aggregator_factory = AggregatorFactory {
            phantom_table: table::new()
        };
        move_to(arx, aggregator_factory);
    }

    /// Creates a new aggregator instance which overflows on exceeding a `limit`.
    public(friend) fun create_aggregator_internal(limit: u128): Aggregator acquires AggregatorFactory {
        assert!(
            exists<AggregatorFactory>(@arx),
            error::not_found(EAGGREGATOR_FACTORY_NOT_FOUND)
        );

        let aggregator_factory = borrow_global_mut<AggregatorFactory>(@arx);
        new_aggregator(aggregator_factory, limit)
    }

    /// This is currently a function closed for public. This can be updated in the future by on-chain
    /// governance to allow any signer to call.
    public fun create_aggregator(account: &signer, limit: u128): Aggregator acquires AggregatorFactory {
        // Only Open Libra (0x1) account can call this for now.
        system_addresses::assert_arx(account);
        create_aggregator_internal(limit)
    }

    /// Returns a new aggregator.
    native fun new_aggregator(aggregator_factory: &mut AggregatorFactory, limit: u128): Aggregator;

    #[test_only]
    public fun initialize_aggregator_factory_for_test(arx: &signer) {
        initialize_aggregator_factory(arx);
    }
}
