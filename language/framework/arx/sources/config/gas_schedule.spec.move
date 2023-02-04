spec arx::gas_schedule {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec initialize(arx: &signer, gas_schedule_blob: vector<u8>) {
        use std::signer;

        include system_addresses::AbortsIfNotOpenLibra{ account: arx };
        aborts_if len(gas_schedule_blob) == 0;
        aborts_if exists<GasScheduleV2>(signer::address_of(arx));
        ensures exists<GasScheduleV2>(signer::address_of(arx));
    }

    spec set_gas_schedule(arx: &signer, gas_schedule_blob: vector<u8>) {
        use std::signer;
        use arx::util;
        use arx::validator;
        use arx::coin::CoinInfo;
        use arx::arx_coin::ArxCoin;

        requires exists<validator::ValidatorFees>(@arx);
        requires exists<CoinInfo<ArxCoin>>(@arx);

        include system_addresses::AbortsIfNotOpenLibra{ account: arx };
        aborts_if len(gas_schedule_blob) == 0;
        let new_gas_schedule = util::spec_from_bytes<GasScheduleV2>(gas_schedule_blob);
        let gas_schedule = global<GasScheduleV2>(@arx);
        aborts_if exists<GasScheduleV2>(@arx) && new_gas_schedule.feature_version < gas_schedule.feature_version;
        ensures exists<GasScheduleV2>(signer::address_of(arx));
    }

    spec set_storage_gas_config(arx: &signer, config: StorageGasConfig) {
        use arx::validator;
        use arx::coin::CoinInfo;
        use arx::arx_coin::ArxCoin;

        requires exists<validator::ValidatorFees>(@arx);
        requires exists<CoinInfo<ArxCoin>>(@arx);

        include system_addresses::AbortsIfNotOpenLibra{ account: arx };
        aborts_if !exists<StorageGasConfig>(@arx);
    }
}
