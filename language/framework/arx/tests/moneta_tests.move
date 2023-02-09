#[test_only]
module arx::moneta_tests {
    use arx::arx_coin;//::{Self, ArxCoin};
    use arx::xusd_coin;//::{Self, XUSDCoin};
    //use arx::curves::Stable;
    //use arx::liquidity_pool;
    use arx::genesis;
    use arx::moneta;

    #[test(arx = @arx)]
    fun test_create_pool_moneta(arx: signer) {
	genesis::setup();
        let (arx_burn_cap, arx_mint_cap) = arx_coin::initialize(&arx);
	let (xusd_burn_cap, xusd_mint_cap) = xusd_coin::initialize(&arx);
	// Give `moneta` module MintCapability<ArxCoin> so it can mint `ARX`.
	moneta::store_arx_coin_mint_cap(&arx, arx_mint_cap, arx_burn_cap);
	// Give `moneta` module MintCapability<XUSD> so it can mint `XUSD` (testing only).
	moneta::store_xusd_coin_mint_cap(&arx, xusd_mint_cap, xusd_burn_cap);

	//coin::destroy_burn_cap(arx_burn_cap);
	//coin::destroy_burn_cap(xusd_burn_cap);
	
        moneta::initialize_for_testing(&arx);
    }
}
