spec arx::reconfiguration {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;

        // After genesis, `Configuration` exists.
        invariant [suspendable] chain_status::is_operating() ==> exists<Configuration>(@arx);
        invariant [suspendable] chain_status::is_operating() ==>
            (timestamp::spec_now_microseconds() >= last_reconfiguration_time());
    }

    /// Make sure the signer address is @arx.
    spec schema AbortsIfNotOpenLibra {
        arx: &signer;

        let addr = signer::address_of(arx);
        aborts_if !system_addresses::is_arx_address(addr);
    }

    /// Address @arx must exist resource Account and Configuration.
    /// Already exists in framework account.
    /// Guid_creation_num should be 2 according to logic.
    spec initialize(arx: &signer) {
        use std::signer;
        use arx::account::{Account};

        include AbortsIfNotOpenLibra;
        let addr = signer::address_of(arx);
        requires exists<Account>(addr);
        aborts_if !(global<Account>(addr).guid_creation_num == 2);
        aborts_if exists<Configuration>(@arx);
    }

    spec current_epoch(): u64 {
        aborts_if !exists<Configuration>(@arx);
    }

    spec disable_reconfiguration(arx: &signer) {
        include AbortsIfNotOpenLibra;
        aborts_if exists<DisableReconfiguration>(@arx);
    }

    /// Make sure the caller is admin and check the resource DisableReconfiguration.
    spec enable_reconfiguration(arx: &signer) {
        use arx::reconfiguration::{DisableReconfiguration};
        include AbortsIfNotOpenLibra;
        aborts_if !exists<DisableReconfiguration>(@arx);
    }

    /// When genesis_event emit the epoch and the `last_reconfiguration_time` .
    /// Should equal to 0
    spec emit_genesis_reconfiguration_event {
        use arx::reconfiguration::{Configuration};

        aborts_if !exists<Configuration>(@arx);
        let config_ref = global<Configuration>(@arx);
        aborts_if !(config_ref.epoch == 0 && config_ref.last_reconfiguration_time == 0);
    }

    spec last_reconfiguration_time {
        aborts_if !exists<Configuration>(@arx);
    }

    spec reconfigure {
        use arx::coin::CoinInfo;
        use arx::arx_coin::ArxCoin;

        requires exists<validator::ValidatorFees>(@arx);
        requires exists<CoinInfo<ArxCoin>>(@arx);

        aborts_if false;
    }
}
