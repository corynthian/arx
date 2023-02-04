spec arx::governance {
    spec reconfigure {
        use arx::chain_status;
        use arx::coin::CoinInfo;
        use arx::arx_coin::ArxCoin;

        requires chain_status::is_operating();
        requires timestamp::spec_now_microseconds() >= reconfiguration::last_reconfiguration_time();
        requires exists<validator::ValidatorFees>(@arx);
        requires exists<CoinInfo<ArxCoin>>(@arx);
    }
}
