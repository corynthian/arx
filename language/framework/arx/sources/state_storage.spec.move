spec arx::state_storage {
    spec module {
        use std::chain_status;
        pragma verify = true;
        pragma aborts_if_is_strict;
        // After genesis, `StateStorageUsage` and `GasParameter` exist.
        invariant [suspendable] chain_status::is_operating() ==> exists<StateStorageUsage>(@arx);
        invariant [suspendable] chain_status::is_operating() ==> exists<GasParameter>(@arx);
    }

    /// ensure caller is admin.
    /// aborts if StateStorageUsage already exists.
    spec initialize(arx: &signer) {
        use std::signer;
        let addr = signer::address_of(arx);
        aborts_if !system_addresses::is_arx_address(addr);
        aborts_if exists<StateStorageUsage>(@arx);
    }

    spec on_new_block(epoch: u64) {
        use std::chain_status;
        requires chain_status::is_operating();
        aborts_if false;
    }

    spec current_items_and_bytes(): (u64, u64) {
        aborts_if !exists<StateStorageUsage>(@arx);
    }

    spec get_state_storage_usage_only_at_epoch_beginning(): Usage {
        // TODO: temporary mockup.
        pragma opaque;
    }

    spec on_reconfig {
        aborts_if true;
    }
}
