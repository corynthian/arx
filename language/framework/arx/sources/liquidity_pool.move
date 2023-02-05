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

    // Error codes.

    /// When coins used to create pair have the wrong ordering.
    const EINVALID_ORDERING: u64 = 1;

    /// A liquidity pool already exists for this pair.
    const ELIQUIDITY_POOL_EXISTS: u64 = 2;

    /// When not enough liquidity is minted.
    const ENOT_ENOUGH_INITIAL_LIQUIDITY: u64 = 3;

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
	coin_x_reserve: Coin<X>,
	coin_y_reserve: Coin<Y>,
	last_block_timestamp: u64,
	last_price_x_cumulative: u128,
	last_price_y_cumulative: u128,
	lp_mint_cap: coin::MintCapability<LP<X, Y, Curve>>,
	lp_burn_cap: coin::BurnCapability<LP<X, Y, Curve>>,
	x_scale: u64,
	y_scale: u64,
    }

    /// Liquidity pool events.
    struct LiquidityPoolEvents<phantom X, phantom Y, phantom Curve> has key {
	pool_created_events: event::EventHandle<PoolCreatedEvent<X, Y, Curve>>,
	liquidity_added_events: event::EventHandle<LiquidityAddedEvent<X, Y, Curve>>,
	liquidity_removed_events: event::EventHandle<LiquidityRemovedEvent<X, Y, Curve>>,
	swap_events: event::EventHandle<SwapEvent<X, Y, Curve>>,
	oracle_update_events: event::EventHandle<OracleUpdatedEvent<X, Y, Curve>>,
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
    struct OracleUpdatedEvent<phantom X, phantom Y, phantom Curve> has drop, store {
        last_price_x_cumulative: u128,
        last_price_y_cumulative: u128,
    }    

    /// Initializes the genesis liquidity pool state.
    public entry fun initialize(arx_account: &signer) {
	system_addresses::assert_arx(arx_account);
    }

    // Public functions.

    /// Register a liquidity pool for pair `X:Y`. This function is only callable
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
	assert!(!exists<LiquidityPool<X, Y, Curve>>(@arx), ELIQUIDITY_POOL_EXISTS);

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
	    last_block_timestamp: 0,
	    last_price_x_cumulative: 0,
	    last_price_y_cumulative: 0,
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
    acquires LiquidityPool {
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
	    assert!(initial_liq > MINIMUM_LIQUIDITY, ENOT_ENOUGH_INITIAL_LIQUIDITY);
	    initial_liq - MINIMUM_LIQUIDITY
	} else {
	    let x_liq = math128::mul_div((x_provided_val as u128), lp_coins_total, (x_reserve_size as u128));
	    let y_liq = math128::mul_div((y_provided_val as u128), lp_coins_total, (y_reserve_size as u128));
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

	lp_coins
    }

    /// Burn liquidity coins (LP) and get back X and Y from its reserves. Permissionless.
    public fun burn<X, Y, Curve>(lp_coins: Coin<LP<X, Y, Curve>>): (Coin<X>, Coin<Y>)
    acquires LiquidityPool {
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

	(x_coin_to_return, y_coin_to_return)
    }

    /// Swap coins (may swap both x and y at the same time). Permissionless.
    public fun swap<X, Y, Curve>(
	x_in: Coin<X>,
	x_out: u64,
	y_in: Coin<Y>,
	y_out: u64
    ): (Coin<X>, Coin<Y>) acquires LiquidityPool {
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

	(x_swapped, y_swapped)
    }

    // Private functions

    /// Update the cumulative prices (decentralised price oracle).
    fun update_oracle<X, Y, Curve>(
	pool: &mut LiquidityPool<X, Y, Curve>,
	x_reserve: u64,
	y_reserve: u64
    ) {
	let last_block_timestamp = pool.last_block_timestamp;
	let block_timestamp = timestamp::now_seconds();
	let time_elapsed = ((block_timestamp - last_block_timestamp) as u128);
	if (time_elapsed > 0 && x_reserve != 0 && y_reserve != 0) {
	    let last_price_x_cumulative = uq64x64::to_u128(uq64x64::fraction(y_reserve, x_reserve)) * time_elapsed;
	    let last_price_y_cumulative = uq64x64::to_u128(uq64x64::fraction(x_reserve, y_reserve)) * time_elapsed;

	    pool.last_price_x_cumulative = math128::overflow_add(pool.last_price_x_cumulative, last_price_x_cumulative);
	    pool.last_price_y_cumulative = math128::overflow_add(pool.last_price_y_cumulative, last_price_y_cumulative);
	};
	pool.last_block_timestamp = block_timestamp;
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

}
