/// Incitamentum definitionis
module arx::forma {
    use arx::system_addresses;
    use arx::chain_status;
    use arx::arx_coin::ArxCoin;

    use std::error;

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

    #[test(arx = @arx)]
    public entry fun test_initialize(arx: &signer) {
	// Test
	initialize(arx);
	assert_exists<ArxCoin>();
    }
}
