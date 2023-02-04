spec arx::aggregator_factory {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec new_aggregator(aggregator_factory: &mut AggregatorFactory, limit: u128): Aggregator {
        pragma opaque;
        aborts_if false;
        ensures result.limit == limit;
    }

    /// Make sure the caller is @arx.
    /// AggregatorFactory is not under the caller before creating the resource.
    spec initialize_aggregator_factory(arx: &signer) {
        use std::signer;
        let addr = signer::address_of(arx);
        aborts_if addr != @arx;
        aborts_if exists<AggregatorFactory>(addr);
        ensures exists<AggregatorFactory>(addr);
    }

    spec create_aggregator_internal(limit: u128): Aggregator {
        aborts_if !exists<AggregatorFactory>(@arx);
    }

    /// Make sure the caller is @arx.
    /// AggregatorFactory existed under the @arx when Creating a new aggregator.
    spec create_aggregator(account: &signer, limit: u128): Aggregator {
        use std::signer;
        let addr = signer::address_of(account);
        aborts_if addr != @arx;
        aborts_if !exists<AggregatorFactory>(@arx);
    }
}
