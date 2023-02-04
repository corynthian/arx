/// This module defines structs and methods to initialize the gas schedule, which dictates how much
/// it costs to execute Move on the network.
module arx::gas_schedule {
    use std::error;
    use std::string::String;
    use std::vector;

    use arx::reconfiguration;
    use arx::system_addresses;
    use arx::util::from_bytes;
    use arx::storage_gas::StorageGasConfig;
    use arx::storage_gas;

    friend arx::genesis;

    /// The provided gas schedule bytes are empty or invalid
    const EINVALID_GAS_SCHEDULE: u64 = 1;
    const EINVALID_GAS_FEATURE_VERSION: u64 = 2;

    struct GasEntry has store, copy, drop {
        key: String,
        val: u64,
    }

    struct GasSchedule has key, copy, drop {
        entries: vector<GasEntry>
    }

    struct GasScheduleV2 has key, copy, drop {
        feature_version: u64,
        entries: vector<GasEntry>,
    }

    /// Only called during genesis.
    public(friend) fun initialize(arx: &signer, gas_schedule_blob: vector<u8>) {
        system_addresses::assert_arx(arx);
        assert!(!vector::is_empty(&gas_schedule_blob), error::invalid_argument(EINVALID_GAS_SCHEDULE));

        // TODO(Gas): check if gas schedule is consistent
        let gas_schedule: GasScheduleV2 = from_bytes(gas_schedule_blob);
        move_to<GasScheduleV2>(arx, gas_schedule);
    }

    /// This can be called by on-chain governance to update the gas schedule.
    public fun set_gas_schedule(arx: &signer, gas_schedule_blob: vector<u8>) acquires GasSchedule, GasScheduleV2 {
        system_addresses::assert_arx(arx);
        assert!(!vector::is_empty(&gas_schedule_blob), error::invalid_argument(EINVALID_GAS_SCHEDULE));

        if (exists<GasScheduleV2>(@arx)) {
            let gas_schedule = borrow_global_mut<GasScheduleV2>(@arx);
            let new_gas_schedule: GasScheduleV2 = from_bytes(gas_schedule_blob);
            assert!(new_gas_schedule.feature_version >= gas_schedule.feature_version,
                error::invalid_argument(EINVALID_GAS_FEATURE_VERSION));
            // TODO(Gas): check if gas schedule is consistent
            *gas_schedule = new_gas_schedule;
        }
        else {
            if (exists<GasSchedule>(@arx)) {
                _ = move_from<GasSchedule>(@arx);
            };
            let new_gas_schedule: GasScheduleV2 = from_bytes(gas_schedule_blob);
            // TODO(Gas): check if gas schedule is consistent
            move_to<GasScheduleV2>(arx, new_gas_schedule);
        };

        // Need to trigger reconfiguration so validator nodes can sync on the updated gas schedule.
        reconfiguration::reconfigure();
    }

    public fun set_storage_gas_config(arx: &signer, config: StorageGasConfig) {
        storage_gas::set_config(arx, config);
        // Need to trigger reconfiguration so the VM is guaranteed to load the new gas fee starting from the next
        // transaction.
        reconfiguration::reconfigure();
    }
}
