/// Incitamentum definitionis
module arx::forma {
    use arx::arx_coin::ArxCoin;
    use arx::chain_status;
    use arx::lp_coin::LP;
    use arx::system_addresses;
    use arx::xusd_coin::XUSDCoin;

    use std::curves::Stable;
    use std::error;

    friend arx::genesis;

    struct Forma<phantom CoinType> has key {
	/// The lux incentive of this forma.
	lux_incentive: u64,
	/// The nox incentive of this forma.
	nox_incentive: u64,
    }

    /// A forma was not found for the specified coin type.
    const EFORMA_NOT_FOUND: u64 = 1;

    /// Initialises the bona configuration.
    /// Called at genesis and required in order to initialize the validator set.
    public(friend) fun initialize(arx_account: &signer) {
	system_addresses::assert_arx(arx_account);
	chain_status::assert_genesis();

	register<ArxCoin>(arx_account, 1, 1);
	register<LP<ArxCoin, XUSDCoin, Stable>>(arx_account, 1, 1);
    }

    /// Registers a new forma which allows for the existence of a solaris of the same coin type.
    public fun register<CoinType>(
	arx_account: &signer,
	lux_incentive: u64,
	nox_incentive: u64,
    ) {
	system_addresses::assert_arx(arx_account);
	move_to(arx_account, Forma<CoinType> {
	    lux_incentive,
	    nox_incentive,
	});
    }

    /// Ensures a coin type is permitted to be added to servo.
    public fun assert_exists<CoinType>() {
	assert!(exists<Forma<CoinType>>(@arx), error::not_found(EFORMA_NOT_FOUND));
    }

    /// Returns the lux incentive of the forma.
    public fun get_lux_incentive<CoinType>(): u64 acquires Forma {
	borrow_global<Forma<CoinType>>(@arx).lux_incentive
    }

    /// Returns the nox incentive of the forma.
    public fun get_nox_incentive<CoinType>(): u64 acquires Forma {
	borrow_global<Forma<CoinType>>(@arx).nox_incentive
    }

    // /// Set the lux incentive of an existing forma.
    // /// This is used to dynamically adjust liquidity token incentives.
    // public fun set_lux_incentive<CoinType>(value: u64) acquires Forma {
    // 	let forma = borrow_global_mut<Forma<CoinType>>(@arx);
    // 	forma.lux_incentive = value;
    // }

    // /// Set the nox incentive of an existing forma.
    // /// This is used to dynamically adjust liquidity token incentives.
    // public fun set_nox_incentive<CoinType>(value: u64) acquires Forma {
    // 	let forma = borrow_global_mut<Forma<CoinType>>(@arx);
    // 	forma.nox_incentive = value;
    // }

    #[test(arx = @arx)]
    public entry fun test_initialize(arx: &signer) {
	// Test
	initialize(arx);
	assert_exists<ArxCoin>();
    }
}
