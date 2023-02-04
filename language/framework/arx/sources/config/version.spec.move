spec arx::version {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec set_version(account: &signer, major: u64) {
        use std::signer;
        use arx::chain_status;
        use arx::timestamp;
        use arx::validator;
        use arx::coin::CoinInfo;
        use arx::arx_coin::ArxCoin;

        requires chain_status::is_operating();
        requires timestamp::spec_now_microseconds() >= reconfiguration::last_reconfiguration_time();
        requires exists<validator::ValidatorFees>(@arx);
        requires exists<CoinInfo<ArxCoin>>(@arx);

        aborts_if !exists<SetVersionCapability>(signer::address_of(account));
        aborts_if !exists<Version>(@arx);

        let old_major = global<Version>(@arx).major;
        aborts_if !(old_major < major);
    }

    /// Abort if resource already exists in `@arx` when initializing.
    spec initialize(arx: &signer, initial_version: u64) {
        use std::signer;

        aborts_if signer::address_of(arx) != @arx;
        aborts_if exists<Version>(@arx);
        aborts_if exists<SetVersionCapability>(@arx);
    }

    /// This module turns on `aborts_if_is_strict`, so need to add spec for test function
    /// `initialize_for_test`.
    spec initialize_for_test {
        // Don't verify test functions.
        pragma verify = false;
    }
}
