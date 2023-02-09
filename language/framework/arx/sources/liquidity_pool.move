/// A feeless liquidity pool implementation. Initialised at genesis and subsequently controlled by the
/// Arx governance account. 
module arx::liquidity_pool {
    use std::event;
    use std::u256;
    use std::uq64x64;
    use std::coin_type;
    use std::curves;
    use std::math64;
    use std::math128;
    use std::stable_curve;

    use arx::account;
    use arx::coin::{Self, Coin};
    use arx::timestamp;
    use arx::system_addresses;
    use arx::reconfiguration;

    // Error codes.

    /// When coins used to create pair have the wrong ordering.
    const EINVALID_ORDERING: u64 = 1;
    /// A liquidity pool already exists for this pair.
    const EPOOL_EXISTS: u64 = 2;
    /// When not enough liquidity is minted.
    const EINSUFFICIENT_INITIAL_LIQUIDITY: u64 = 3;
    /// When not enough liquidity is minted.
    const EINSUFFICIENT_LIQUIDITY: u64 = 4;
    /// Supplied X and Y for a swap was equal to zero.
    const EZERO_COIN_IN: u64 = 5;
    /// Triggered by a swap which causes liquidity to decrease.
    const EINVALID_SWAP: u64 = 6;
    /// This error should never occur.
    const EINVALID_CURVE: u64 = 7;
    /// Incorrect lp coin burn values
    const EINVALID_BURN_VALUES: u64 = 8;
    /// When pool doesn't exists for pair.
    const EPOOL_DOES_NOT_EXIST: u64 = 9;

    // Constants.

    /// Minimum liquidity.
    const MINIMUM_LIQUIDITY: u64 = 1000;
    
    /// LP coin type.
    struct LP<phantom X, phantom Y, phantom Curve> {}

    /// Liquidity pool with cumulative price aggregation.
    struct LiquidityPool<phantom X, phantom Y, phantom Curve> has key {
	/// The amount of coin `X` held in reserves.
	coin_x_reserve: Coin<X>,
	/// The amount of coin `Y` held in reserves.
	coin_y_reserve: Coin<Y>,
	/// The timestamp of the last epoch where the oracle is updated.
	last_epoch_timestamp: u64,
	/// The timestamp of the last block where the oracle was updated.
	last_block_timestamp: u64,
	/// The last cumulative price in `X`.
	last_price_x_cumulative: u128,
	/// The last cumulative price in `Y`.
	last_price_y_cumulative: u128,
	/// The last cumulative reserve in `X`.
	last_x_reserve_cumulative: u128,
	/// The last cumulative reserve in `Y`.
	last_y_reserve_cumulative: u128,
	/// The number of cumulative price samples taken across the last epoch.
	epoch_samples: u128,
	/// The time weighted average price of `X` relative to `Y`.
	epoch_twap_x: u128,
	/// The time weighted average price in `Y` relative to `X`.
	epoch_twap_y: u128,
	/// The time weighted average reserves of `X`.
	epoch_twar_x: u128,
	/// The time weighted average reserves of `Y`.
	epoch_twar_y: u128,
	/// The liquidity pools mint capability.
	lp_mint_cap: coin::MintCapability<LP<X, Y, Curve>>,
	/// The liquidity pools burn capability.
	lp_burn_cap: coin::BurnCapability<LP<X, Y, Curve>>,
	/// The scaling factor of coin `X`.
	x_scale: u64,
	/// The scaling factor of coin `Y`.
	y_scale: u64,
    }

    // Delta enumeration

    /// Delta zero
    const DELTA_EQUAL: u64 = 0;
    /// Delta positive sign
    const DELTA_POSITIVE: u64 = 1;
    /// Delta negative sign
    const DELTA_NEGATIVE: u64 = 2;

    /// Represents the time weighted average reserve of X in the last epoch.
    struct Delta has drop {
	/// Whether X > Y, Y > X or X = Y
	sign: u64,
	/// The cumulative difference in X vs Y
	value: u64,
    }
    public fun get_delta_sign(delta: &Delta): u64 {
	delta.sign
    }
    public fun get_delta_value(delta: &Delta): u64 {
	delta.value
    }

    /// Liquidity pool events.
    struct LiquidityPoolEvents<phantom X, phantom Y, phantom Curve> has key {
	pool_created_events: event::EventHandle<PoolCreatedEvent<X, Y, Curve>>,
	liquidity_added_events: event::EventHandle<LiquidityAddedEvent<X, Y, Curve>>,
	liquidity_removed_events: event::EventHandle<LiquidityRemovedEvent<X, Y, Curve>>,
	swap_events: event::EventHandle<SwapEvent<X, Y, Curve>>,
	oracle_update_events: event::EventHandle<OracleUpdateEvent<X, Y, Curve>>,
    }

    /// A new liquidity pool has been created.
    struct PoolCreatedEvent<phantom X, phantom Y, phantom Curve> has drop, store { }

    /// Liquidity was added to an existing pool.
    struct LiquidityAddedEvent<phantom X, phantom Y, phantom Curve> has drop, store {
        added_x_val: u64,
        added_y_val: u64,
        lp_tokens_received: u64,
    }

    /// Liquidity was removed from an existing pool.
    struct LiquidityRemovedEvent<phantom X, phantom Y, phantom Curve> has drop, store {
        returned_x_val: u64,
        returned_y_val: u64,
        lp_tokens_burned: u64,
    }

    /// A swap was made in a liquidity pool.
    struct SwapEvent<phantom X, phantom Y, phantom Curve> has drop, store {
        x_in: u64,
        x_out: u64,
        y_in: u64,
        y_out: u64,
    }

    /// The cumulative price oracle was updated.
    struct OracleUpdateEvent<phantom X, phantom Y, phantom Curve> has drop, store {
        last_price_x_cumulative: u128,
        last_price_y_cumulative: u128,
	epoch_samples: u128,
	epoch_twap_x: u128,
	epoch_twap_y: u128,
    }    

    // Public functions.

    /// Register a liquidity pool for pair `X:Y`. This function is only callable by the `arx` account.
    public fun register<X, Y, Curve>(arx_account: &signer) {
	// Ensure only the arx account at genesis or subsequently governance can register a new pool.
	system_addresses::assert_arx(arx_account);

	// Ensure coin types are initialized a priori.
	coin_type::assert_coin_initialized<X>();
	coin_type::assert_coin_initialized<Y>();

	// Ensure pair order correctness.
	assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);

	// Ensure valid curve.
	curves::assert_valid_curve<Curve>();

	// Ensure the liquidity pool does not already exist.
	assert!(!exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_EXISTS);

	let (lp_name, lp_symbol) = coin_type::generate_lp_name_and_symbol<X, Y, Curve>();
	let (lp_burn_cap, lp_freeze_cap, lp_mint_cap) =
	    coin::initialize<LP<X, Y, Curve>>(
		arx_account,
		lp_name,
		lp_symbol,
		6,
		true
	    );
	coin::destroy_freeze_cap(lp_freeze_cap);

	let x_scale = 0;
	let y_scale = 0;

	if (curves::is_stable<Curve>()) {
	    x_scale = math64::pow_10(coin::decimals<X>());
	    y_scale = math64::pow_10(coin::decimals<Y>());
	};

	let pool = LiquidityPool<X, Y, Curve> {
	    coin_x_reserve: coin::zero<X>(),
	    coin_y_reserve: coin::zero<Y>(),
	    last_epoch_timestamp: reconfiguration::last_reconfiguration_time(),
	    last_block_timestamp: 0,
	    last_price_x_cumulative: 0,
	    last_price_y_cumulative: 0,
	    last_x_reserve_cumulative: 0,
	    last_y_reserve_cumulative: 0,
	    epoch_samples: 0,
	    epoch_twap_x: 0,
	    epoch_twap_y: 0,
	    epoch_twar_x: 0,
	    epoch_twar_y: 0,
	    lp_mint_cap,
	    lp_burn_cap,
	    x_scale,
	    y_scale,
	};
	move_to(arx_account, pool);

	let lp_events = LiquidityPoolEvents<X, Y, Curve> {
            pool_created_events: account::new_event_handle(arx_account),
            liquidity_added_events: account::new_event_handle(arx_account),
            liquidity_removed_events: account::new_event_handle(arx_account),
            swap_events: account::new_event_handle(arx_account),
            oracle_update_events: account::new_event_handle(arx_account),
	};
	event::emit_event(
	    &mut lp_events.pool_created_events,
	    PoolCreatedEvent<X, Y, Curve> {},
	);
	move_to(arx_account, lp_events);
    }

    /// Mint new liquidity. Permissionless.
    /// * `coin_x` - coin X to add to the liquidity reserves.
    /// * `coin_y` - coin Y to add to the liquidity reserves.
    /// Returns LP coins: `Coin<LP<X, Y, Curve>>`.
    public fun mint<X, Y, Curve>(coin_x: Coin<X>, coin_y: Coin<Y>): Coin<LP<X, Y, Curve>>
	acquires LiquidityPool, LiquidityPoolEvents
    {
	assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
	assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

	let lp_coins_total = coin_type::supply<LP<X, Y, Curve>>();

	let pool = borrow_global_mut<LiquidityPool<X, Y, Curve>>(@arx);
	let x_reserve_size = coin::value(&pool.coin_x_reserve);
	let y_reserve_size = coin::value(&pool.coin_y_reserve);

	let x_provided_val = coin::value<X>(&coin_x);
	let y_provided_val = coin::value<Y>(&coin_y);

	let provided_liq = if (lp_coins_total == 0) {
	    let initial_liq = math128::sqrt(math64::mul_to_u128(x_provided_val, y_provided_val));
	    assert!(initial_liq > MINIMUM_LIQUIDITY, EINSUFFICIENT_INITIAL_LIQUIDITY);
	    initial_liq - MINIMUM_LIQUIDITY
	} else {
	    let x_liq = math128::mul_div(
		(x_provided_val as u128), lp_coins_total, (x_reserve_size as u128)
	    );
	    let y_liq = math128::mul_div(
		(y_provided_val as u128), lp_coins_total, (y_reserve_size as u128)
	    );
	    if (x_liq < y_liq) {
		x_liq
	    } else {
		y_liq
	    }
	};
	assert!(provided_liq > 0, EINSUFFICIENT_LIQUIDITY);

	coin::merge(&mut pool.coin_x_reserve, coin_x);
	coin::merge(&mut pool.coin_y_reserve, coin_y);

	let lp_coins = coin::mint<LP<X, Y, Curve>>(provided_liq, &pool.lp_mint_cap);

	update_oracle<X, Y, Curve>(pool, x_reserve_size, y_reserve_size);

	let lp_events = borrow_global_mut<LiquidityPoolEvents<X, Y, Curve>>(@arx);
	event::emit_event(
	    &mut lp_events.liquidity_added_events,
	    LiquidityAddedEvent<X, Y, Curve> {
		added_x_val: x_provided_val,
		added_y_val: y_provided_val,
		lp_tokens_received: provided_liq
	    }
	);

	lp_coins
    }

    /// Burn liquidity coins (LP) and get back X and Y from its reserves. Permissionless.
    public fun burn<X, Y, Curve>(lp_coins: Coin<LP<X, Y, Curve>>): (Coin<X>, Coin<Y>)
    acquires LiquidityPool, LiquidityPoolEvents {
	assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
	assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

	let burned_lp_coins_val = coin::value(&lp_coins);

	let pool = borrow_global_mut<LiquidityPool<X, Y, Curve>>(@arx);

	let lp_coins_total = coin_type::supply<LP<X, Y, Curve>>();
	let x_reserve_val = coin::value(&pool.coin_x_reserve);
	let y_reserve_val = coin::value(&pool.coin_y_reserve);

	// Compute x, y coin values for provided lp_coins value
	let x_to_return_val = math128::mul_div((burned_lp_coins_val as u128), (x_reserve_val as u128), lp_coins_total);
	let y_to_return_val = math128::mul_div((burned_lp_coins_val as u128), (y_reserve_val as u128), lp_coins_total);
	assert!(x_to_return_val > 0 && y_to_return_val > 0, EINVALID_BURN_VALUES);

	// Withdraw values from reserves
	let x_coin_to_return = coin::extract(&mut pool.coin_x_reserve, x_to_return_val);
	let y_coin_to_return = coin::extract(&mut pool.coin_y_reserve, y_to_return_val);

	update_oracle<X, Y, Curve>(pool, x_reserve_val, y_reserve_val);
	coin::burn(lp_coins, &pool.lp_burn_cap);

	let lp_events = borrow_global_mut<LiquidityPoolEvents<X, Y, Curve>>(@arx);
	event::emit_event(
	    &mut lp_events.liquidity_removed_events,
	    LiquidityRemovedEvent<X, Y, Curve> {
		returned_x_val: x_to_return_val,
		returned_y_val: y_to_return_val,
		lp_tokens_burned: burned_lp_coins_val,
	    });

	(x_coin_to_return, y_coin_to_return)
    }

    /// Swap coins (may swap both x and y at the same time). Permissionless.
    public fun swap<X, Y, Curve>(
	x_in: Coin<X>,
	x_out: u64,
	y_in: Coin<Y>,
	y_out: u64
    ): (Coin<X>, Coin<Y>) acquires LiquidityPool, LiquidityPoolEvents {
	assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
	assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

	let x_in_val = coin::value(&x_in);
	let y_in_val = coin::value(&y_in);

	assert!(x_in_val > 0 || y_in_val > 0, EZERO_COIN_IN);

	let pool = borrow_global_mut<LiquidityPool<X, Y, Curve>>(@arx);
	let x_reserve_size = coin::value(&pool.coin_x_reserve);
	let y_reserve_size = coin::value(&pool.coin_y_reserve);

	// Deposit new coins in the liquidity pool.
	coin::merge(&mut pool.coin_x_reserve, x_in);
	coin::merge(&mut pool.coin_y_reserve, y_in);

	// Withdraw expected amount from reserves.
	let x_swapped = coin::extract(&mut pool.coin_x_reserve, x_out);
	let y_swapped = coin::extract(&mut pool.coin_y_reserve, y_out);

	// Ensure the lp_value of the pool hasn't decreased.
	assert_lp_value_increase<Curve>(
	    pool.x_scale,
	    pool.y_scale,
	    (x_reserve_size as u128),
	    (y_reserve_size as u128),
	    (coin::value(&pool.coin_x_reserve) as u128),
	    (coin::value(&pool.coin_y_reserve) as u128)
	);

	update_oracle<X, Y, Curve>(pool, x_reserve_size, y_reserve_size);

	let lp_events = borrow_global_mut<LiquidityPoolEvents<X, Y, Curve>>(@arx);
	event::emit_event(
	    &mut lp_events.swap_events,
	    SwapEvent<X, Y, Curve> {
		x_in: x_in_val,
		y_in: y_in_val,
		x_out,
		y_out,
	    });

	(x_swapped, y_swapped)
    }

    // Private functions

    /// Update the cumulative prices (decentralised price oracle).
    fun update_oracle<X, Y, Curve>(
	pool: &mut LiquidityPool<X, Y, Curve>,
	x_reserve: u64,
	y_reserve: u64
    ) acquires LiquidityPoolEvents {
	let last_epoch_timestamp = reconfiguration::last_reconfiguration_time();
	if (last_epoch_timestamp > pool.last_epoch_timestamp) {
	    // Reset the number of time samples taken to 0.
	    pool.epoch_samples = 0;
	    // Set the pools last epoch timestamp to the new epoch.
	    pool.last_epoch_timestamp = last_epoch_timestamp;
	};

	let last_block_timestamp = pool.last_block_timestamp;
	let block_timestamp = timestamp::now_seconds();
	let time_elapsed = ((block_timestamp - last_block_timestamp) as u128);
	if (time_elapsed > 0 && x_reserve != 0 && y_reserve != 0) {
	    // If the number of epoch samples is 0, then the pools last cumulative price is reset.
	    // Note that this is done after checking that a new sample can be taken since otherwise the
	    // last cumulative price will be 0 until a next successful oracle update is initiated.
	    // This also makes it less likely that there will be a price overflow when computing the
	    // cumulative price.
	    if (pool.epoch_samples == 0) {
		pool.last_x_reserve_cumulative = 0;
		pool.last_y_reserve_cumulative = 0;
		pool.last_price_x_cumulative = 0;
		pool.last_price_y_cumulative = 0;
	    };

	    let last_price_x_cumulative =
		uq64x64::to_u128(uq64x64::fraction(y_reserve, x_reserve)) * time_elapsed;
	    let last_price_y_cumulative =
		uq64x64::to_u128(uq64x64::fraction(x_reserve, y_reserve)) * time_elapsed;
	    pool.last_price_x_cumulative =
		math128::overflow_add(pool.last_price_x_cumulative, last_price_x_cumulative);
	    pool.last_price_y_cumulative =
		math128::overflow_add(pool.last_price_y_cumulative, last_price_y_cumulative);

	    let last_x_reserve_cumulative = (x_reserve as u128) * time_elapsed;
	    let last_y_reserve_cumulative = (y_reserve as u128) * time_elapsed;
	    pool.last_x_reserve_cumulative =
		math128::overflow_add(pool.last_x_reserve_cumulative, last_x_reserve_cumulative);
	    pool.last_y_reserve_cumulative =
		math128::overflow_add(pool.last_y_reserve_cumulative, last_y_reserve_cumulative);

	    pool.epoch_samples = pool.epoch_samples + 1;
	    pool.epoch_twap_x = pool.last_price_x_cumulative / pool.epoch_samples;
	    pool.epoch_twap_y = pool.last_price_y_cumulative / pool.epoch_samples;
	    pool.epoch_twar_x = pool.last_x_reserve_cumulative / pool.epoch_samples;
	    pool.epoch_twar_y = pool.last_y_reserve_cumulative / pool.epoch_samples;

	    let lp_events = borrow_global_mut<LiquidityPoolEvents<X, Y, Curve>>(@arx);
	    event::emit_event(
		&mut lp_events.oracle_update_events,
		OracleUpdateEvent<X, Y, Curve> {
		    last_price_x_cumulative: pool.last_price_x_cumulative,
		    last_price_y_cumulative: pool.last_price_y_cumulative,
		    epoch_samples: pool.epoch_samples,
		    epoch_twap_x: pool.epoch_twap_x,
		    epoch_twap_y: pool.epoch_twap_y,
		});
	};
	pool.last_block_timestamp = block_timestamp;
    }

    /// Get the time weighted average excess / shortage of `X` relative to `Y`.
    public fun get_last_epoch_delta<X, Y, Curve>(): Delta acquires LiquidityPool {
	assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
	assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

	let pool = borrow_global<LiquidityPool<X, Y, Curve>>(@arx);

	// If there is an excess of X in reserves then the sign is negative
	if (pool.epoch_twar_x > pool.epoch_twar_y) {
	    Delta { sign: DELTA_NEGATIVE, value: ((pool.epoch_twar_x - pool.epoch_twar_y) as u64) }
	} else if (pool.epoch_twar_y > pool.epoch_twar_x) {
	    // If there is a shortage of X in reserves then the sign is positive
	    Delta { sign: DELTA_POSITIVE, value: ((pool.epoch_twar_y - pool.epoch_twar_x) as u64) }
	} else {
	    // Otherwise sign is equal
	    Delta { sign: DELTA_EQUAL, value: 0 }
	}
    }

    fun assert_lp_value_increase<Curve>(
	x_scale: u64,
	y_scale: u64,
	x_res: u128,
	y_res: u128,
	new_x_res: u128,
	new_y_res: u128
    ) {
	if (curves::is_stable<Curve>()) {
	    let lp_value_before_swap = stable_curve::lp_value(x_res, x_scale, y_res, y_scale);
	    let lp_value_after_swap = stable_curve::lp_value(new_x_res, x_scale, new_y_res, y_scale);
	    let cmp = u256::compare(&lp_value_after_swap, &lp_value_before_swap);
	    assert!(cmp == 2, EINVALID_SWAP);
	} else if (curves::is_uncorrelated<Curve>()) {
	    let lp_value_before_swap = u256::from_u128(x_res * y_res);
	    let lp_value_after_swap = u256::mul(
		u256::from_u128(new_x_res),
		u256::from_u128(new_y_res)
	    );
	    let cmp = u256::compare(&lp_value_after_swap, &lp_value_before_swap);
	    assert!(cmp == 2, EINVALID_SWAP);
	} else {
	    abort EINVALID_CURVE
	};
    }

    // Getters

    /// Get the reserves of a pool.
    public fun get_reserve_values<X, Y, Curve>(): (u64, u64)
	acquires LiquidityPool {
        assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
        assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

        let liquidity_pool = borrow_global<LiquidityPool<X, Y, Curve>>(@arx);
        let x_reserve = coin::value(&liquidity_pool.coin_x_reserve);
        let y_reserve = coin::value(&liquidity_pool.coin_y_reserve);

        (x_reserve, y_reserve)
    }


    /// Get decimals scales (10^X decimals, 10^Y decimals) for stable curve.
    /// For uncorrelated curve would return just zeros.
    public fun get_decimals_scales<X, Y, Curve>(): (u64, u64) acquires LiquidityPool {
        assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
        assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

        let pool = borrow_global<LiquidityPool<X, Y, Curve>>(@arx);
        (pool.x_scale, pool.y_scale)
    }

    /// Get the current cumulative prices of `X` and `Y`.
    public fun get_cumulative_prices<X, Y, Curve>(): (u128, u128, u64)
	acquires LiquidityPool
    {
	assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
	assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

	let liquidity_pool = borrow_global<LiquidityPool<X, Y, Curve>>(@arx);
	let last_price_x_cumulative = *&liquidity_pool.last_price_x_cumulative;
	let last_price_y_cumulative = *&liquidity_pool.last_price_y_cumulative;
	let last_block_timestamp = liquidity_pool.last_block_timestamp;

	(last_price_x_cumulative, last_price_y_cumulative, last_block_timestamp)
    }

    // Get the current epoch time weighted average prices of `X` and `Y`.
    public fun get_epoch_twap<X, Y, Curve>(): (u128, u128, u64)
	acquires LiquidityPool
    {
	assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
	assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

	let liquidity_pool = borrow_global<LiquidityPool<X, Y, Curve>>(@arx);
	let epoch_twap_x = *&liquidity_pool.epoch_twap_x;
	let epoch_twap_y = *&liquidity_pool.epoch_twap_y;
	let last_epoch_timestamp = liquidity_pool.last_block_timestamp;

	(epoch_twap_x, epoch_twap_y, last_epoch_timestamp)
    }

    // Get the current epoch time weighted average reserves of `X` and `Y`.
    public fun get_epoch_twar<X, Y, Curve>(): (u128, u128)
	acquires LiquidityPool
    {
	assert!(coin_type::preserves_ordering<X, Y>(), EINVALID_ORDERING);
	assert!(exists<LiquidityPool<X, Y, Curve>>(@arx), EPOOL_DOES_NOT_EXIST);

	let liquidity_pool = borrow_global<LiquidityPool<X, Y, Curve>>(@arx);
	let epoch_twar_x = *&liquidity_pool.epoch_twar_x;
	let epoch_twar_y = *&liquidity_pool.epoch_twar_y;
	(epoch_twar_x, epoch_twar_y)
    }
}
