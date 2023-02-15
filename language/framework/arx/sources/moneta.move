/// The purpose of the moneta is to distribute `ARX` to members of the subsidialis, the senatus and the
/// danistae.
module arx::moneta {
    use arx::arx_coin::ArxCoin;
    use arx::delta::{Self, Delta};
    use arx::liquidity_pool;
    use arx::lp_coin::LP;
    use arx::subsidialis;
    use arx::system_addresses;
    use arx::xusd_coin::XUSDCoin;

    use std::uq64x64;
    use std::curves::Stable;
    use std::coin::{Self, MintCapability, BurnCapability};

    friend arx::genesis;
    friend arx::reconfiguration;
    #[test_only]
    friend arx::moneta_tests;

    struct Moneta has key {}
    
    public fun initialize_for_testing(arx: &signer)
	acquires ArxCoinCapability, XUSDCoinCapability
    {
	system_addresses::assert_arx(arx);

	// Initialise the monetas price oracle.
	liquidity_pool::register<ArxCoin, XUSDCoin, Stable>(arx);

	// Mint 1000:1000 ARX against XUSDCoin
	let arx_mint_cap = &borrow_global<ArxCoinCapability>(@arx).mint_cap;
	let arx_initial_coins = coin::mint<ArxCoin>(1001, arx_mint_cap);
	let xusd_mint_cap = &borrow_global<XUSDCoinCapability>(@arx).mint_cap;
	let xusd_initial_coins = coin::mint<XUSDCoin>(1001, xusd_mint_cap);
	// Add 1000:1000 to the liquidity pool
	let initial_liquidity =
	    liquidity_pool::mint<ArxCoin, XUSDCoin, Stable>(arx_initial_coins, xusd_initial_coins);
	// Burn the `ARX` liquidity tokens, rendering them unusable
	liquidity_pool::burn_destructive<ArxCoin, XUSDCoin, Stable>(initial_liquidity);
    }

    public(friend) fun on_new_epoch()
	acquires ArxCoinCapability
    {
	// Fetch the Arx delta for this epoch according to the price oracle.
	let delta = liquidity_pool::get_last_epoch_delta<ArxCoin, XUSDCoin, Stable>();
	// If the deltaA is positive >1:
	if (delta::get_delta_value(&delta) == 1) {
	    // Calculate the share of new mints owed to the subsidialis (TODO: and the senatus).
	    let (subsidialis_share, _daenistae_share) = calculate_mint_shares(&delta);
	    // Calculate the share of subsidialis mints between `ArxCoin` and `LP<..>`.
	    let (subsidialis_arx_mints, subsidialis_lp_mints) =
		calculate_subsidialis_mints(subsidialis_share);
	    // Mint thew `ARX` and distribute the mints to the subsidialis
	    let arx_mint_cap = &borrow_global<ArxCoinCapability>(@arx).mint_cap;
	    let subsidialis_arx_coins = coin::mint<ArxCoin>(subsidialis_arx_mints, arx_mint_cap);
	    let subsidialis_lp_coins = coin::mint<ArxCoin>(subsidialis_lp_mints, arx_mint_cap);
	    subsidialis::distribute_mints<ArxCoin>(subsidialis_arx_coins);
	    subsidialis::distribute_mints<LP<ArxCoin, XUSDCoin, Stable>>(subsidialis_lp_coins);
	    // Assign 50% of mints to the danistae.
	    // let _danistae_mints = delta::get_delta_value(&delta) / 2;
	    // Decrease the nexus interest rate.
	} else if (delta::get_delta_value(&delta) == 2) {
	    // If the deltaA is negative <1:
	    // Offer (-deltaA / 2) aes to the danistae.
	    // Increase the interest rate on bonds according to game theoretic incentives.
	} else {
	    // Do nothing.
	}
    }
    
    fun calculate_mint_shares(delta: &Delta): (u64, u64) {
	// TODO: Add senatus
	let subsidialis_share = delta::get_delta_value(delta) / 2;
	let danistae_share = delta::get_delta_value(delta) / 2;
	(subsidialis_share, danistae_share)
    }

    fun calculate_subsidialis_mints(share_of_mints: u64): (u64, u64) {
	// FIXME: This math loses a lot of precision / hacky / erroneous
	let arx_power = subsidialis::get_total_active_power<ArxCoin>();
	let lp_power = subsidialis::get_total_active_power<LP<ArxCoin, XUSDCoin, Stable>>();
	let combined_power = ((arx_power + lp_power as u128) as u64);
	let arx_power_fraction = uq64x64::decode(uq64x64::fraction(arx_power, combined_power));
	let lp_power_fraction = uq64x64::decode(uq64x64::fraction(lp_power, combined_power));
	let arx_mints = arx_power_fraction * share_of_mints;
	let lp_mints = lp_power_fraction * share_of_mints;
	(arx_mints, lp_mints)
    }

    /// The ArxCoinCapability is conferred at genesis and stored in the @core_resouce account.
    /// This allows the `moneta` module to mint `ARX`.
    struct ArxCoinCapability has key {
	mint_cap: MintCapability<ArxCoin>,
	burn_cap: BurnCapability<ArxCoin>,
    }

    /// This is only called during Genesis, which is where MintCapability<ArxCoin> can be created.
    /// Beyond genesis, no one can create `ArxCoin` mint/burn capabilities.
    public(friend) fun store_arx_coin_mint_cap(
	arx: &signer,
	mint_cap: MintCapability<ArxCoin>,
	burn_cap: BurnCapability<ArxCoin>
    ) {
        system_addresses::assert_arx(arx);
        move_to(arx, ArxCoinCapability { mint_cap, burn_cap })
    }

    /// The XUSDCoinCapability (only used for minting XUSDCoin whilst testing).
    struct XUSDCoinCapability has key {
	mint_cap: MintCapability<XUSDCoin>,
	burn_cap: BurnCapability<XUSDCoin>,
    }

    /// This is only called in test networks, works the same as the arx coin capability.
    public(friend) fun store_xusd_coin_mint_cap(
	arx: &signer,
	mint_cap: MintCapability<XUSDCoin>,
	burn_cap: BurnCapability<XUSDCoin>
    ) {
        system_addresses::assert_arx(arx);
        move_to(arx, XUSDCoinCapability { mint_cap, burn_cap })
    }
}
