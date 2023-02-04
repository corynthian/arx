spec arx::timestamp {
    spec module {
        use arx::chain_status;
        invariant chain_status::is_operating() ==> exists<CurrentTimeMicroseconds>(@arx);
    }

    spec update_global_time {
        use arx::chain_status;
        requires chain_status::is_operating();
        include UpdateGlobalTimeAbortsIf;
    }

    spec schema UpdateGlobalTimeAbortsIf {
        account: signer;
        proposer: address;
        timestamp: u64;
        aborts_if !system_addresses::is_vm(account);
        aborts_if (proposer == @vm_reserved) && (spec_now_microseconds() != timestamp);
        aborts_if (proposer != @vm_reserved) && (spec_now_microseconds() >= timestamp);
    }

    spec fun spec_now_microseconds(): u64 {
        global<CurrentTimeMicroseconds>(@arx).microseconds
    }

    spec fun spec_now_seconds(): u64 {
        spec_now_microseconds() / MICRO_CONVERSION_FACTOR
    }
}
