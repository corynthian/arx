
<a name="0x1_liquidity_pool"></a>

# Module `0x1::liquidity_pool`

A feeless liquidity pool implementation. Initialised at genesis and subsequently controlled by the
Arx governance account.


-  [Struct `LP`](#0x1_liquidity_pool_LP)
-  [Resource `LiquidityPool`](#0x1_liquidity_pool_LiquidityPool)
-  [Struct `Delta`](#0x1_liquidity_pool_Delta)
-  [Resource `LiquidityPoolEvents`](#0x1_liquidity_pool_LiquidityPoolEvents)
-  [Struct `PoolCreatedEvent`](#0x1_liquidity_pool_PoolCreatedEvent)
-  [Struct `LiquidityAddedEvent`](#0x1_liquidity_pool_LiquidityAddedEvent)
-  [Struct `LiquidityRemovedEvent`](#0x1_liquidity_pool_LiquidityRemovedEvent)
-  [Struct `SwapEvent`](#0x1_liquidity_pool_SwapEvent)
-  [Struct `OracleUpdateEvent`](#0x1_liquidity_pool_OracleUpdateEvent)
-  [Constants](#@Constants_0)
-  [Function `get_delta_sign`](#0x1_liquidity_pool_get_delta_sign)
-  [Function `get_delta_value`](#0x1_liquidity_pool_get_delta_value)
-  [Function `register`](#0x1_liquidity_pool_register)
-  [Function `mint`](#0x1_liquidity_pool_mint)
-  [Function `burn`](#0x1_liquidity_pool_burn)
-  [Function `swap`](#0x1_liquidity_pool_swap)
-  [Function `update_oracle`](#0x1_liquidity_pool_update_oracle)
-  [Function `get_last_epoch_delta`](#0x1_liquidity_pool_get_last_epoch_delta)
-  [Function `assert_lp_value_increase`](#0x1_liquidity_pool_assert_lp_value_increase)
-  [Function `get_reserve_values`](#0x1_liquidity_pool_get_reserve_values)
-  [Function `get_decimals_scales`](#0x1_liquidity_pool_get_decimals_scales)
-  [Function `get_cumulative_prices`](#0x1_liquidity_pool_get_cumulative_prices)
-  [Function `get_epoch_twap`](#0x1_liquidity_pool_get_epoch_twap)
-  [Function `get_epoch_twar`](#0x1_liquidity_pool_get_epoch_twar)


<pre><code><b>use</b> <a href="account.md#0x1_account">0x1::account</a>;
<b>use</b> <a href="coin.md#0x1_coin">0x1::coin</a>;
<b>use</b> <a href="coin_type.md#0x1_coin_type">0x1::coin_type</a>;
<b>use</b> <a href="../../std/doc/curves.md#0x1_curves">0x1::curves</a>;
<b>use</b> <a href="event.md#0x1_event">0x1::event</a>;
<b>use</b> <a href="../../std/doc/math128.md#0x1_math128">0x1::math128</a>;
<b>use</b> <a href="../../std/doc/math64.md#0x1_math64">0x1::math64</a>;
<b>use</b> <a href="reconfiguration.md#0x1_reconfiguration">0x1::reconfiguration</a>;
<b>use</b> <a href="../../std/doc/stable_curve.md#0x1_stable_curve">0x1::stable_curve</a>;
<b>use</b> <a href="../../std/doc/string.md#0x1_string">0x1::string</a>;
<b>use</b> <a href="system_addresses.md#0x1_system_addresses">0x1::system_addresses</a>;
<b>use</b> <a href="timestamp.md#0x1_timestamp">0x1::timestamp</a>;
<b>use</b> <a href="../../std/doc/u256.md#0x1_u256">0x1::u256</a>;
<b>use</b> <a href="../../std/doc/uq64x64.md#0x1_uq64x64">0x1::uq64x64</a>;
</code></pre>



<a name="0x1_liquidity_pool_LP"></a>

## Struct `LP`

LP coin type.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LP">LP</a>&lt;X, Y, Curve&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_liquidity_pool_LiquidityPool"></a>

## Resource `LiquidityPool`

Liquidity pool with cumulative price aggregation.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>coin_x_reserve: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;X&gt;</code>
</dt>
<dd>
 The amount of coin <code>X</code> held in reserves.
</dd>
<dt>
<code>coin_y_reserve: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;Y&gt;</code>
</dt>
<dd>
 The amount of coin <code>Y</code> held in reserves.
</dd>
<dt>
<code>last_epoch_timestamp: u64</code>
</dt>
<dd>
 The timestamp of the last epoch where the oracle is updated.
</dd>
<dt>
<code>last_block_timestamp: u64</code>
</dt>
<dd>
 The timestamp of the last block where the oracle was updated.
</dd>
<dt>
<code>last_price_x_cumulative: u128</code>
</dt>
<dd>
 The last cumulative price in <code>X</code>.
</dd>
<dt>
<code>last_price_y_cumulative: u128</code>
</dt>
<dd>
 The last cumulative price in <code>Y</code>.
</dd>
<dt>
<code>last_x_reserve_cumulative: u128</code>
</dt>
<dd>
 The last cumulative reserve in <code>X</code>.
</dd>
<dt>
<code>last_y_reserve_cumulative: u128</code>
</dt>
<dd>
 The last cumulative reserve in <code>Y</code>.
</dd>
<dt>
<code>epoch_samples: u128</code>
</dt>
<dd>
 The number of cumulative price samples taken across the last epoch.
</dd>
<dt>
<code>epoch_twap_x: u128</code>
</dt>
<dd>
 The time weighted average price of <code>X</code> relative to <code>Y</code>.
</dd>
<dt>
<code>epoch_twap_y: u128</code>
</dt>
<dd>
 The time weighted average price in <code>Y</code> relative to <code>X</code>.
</dd>
<dt>
<code>epoch_twar_x: u128</code>
</dt>
<dd>
 The time weighted average reserves of <code>X</code>.
</dd>
<dt>
<code>epoch_twar_y: u128</code>
</dt>
<dd>
 The time weighted average reserves of <code>Y</code>.
</dd>
<dt>
<code>lp_mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">liquidity_pool::LP</a>&lt;X, Y, Curve&gt;&gt;</code>
</dt>
<dd>
 The liquidity pools mint capability.
</dd>
<dt>
<code>lp_burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">liquidity_pool::LP</a>&lt;X, Y, Curve&gt;&gt;</code>
</dt>
<dd>
 The liquidity pools burn capability.
</dd>
<dt>
<code>x_scale: u64</code>
</dt>
<dd>
 The scaling factor of coin <code>X</code>.
</dd>
<dt>
<code>y_scale: u64</code>
</dt>
<dd>
 The scaling factor of coin <code>Y</code>.
</dd>
</dl>


</details>

<a name="0x1_liquidity_pool_Delta"></a>

## Struct `Delta`

Represents the time weighted average reserve of X in the last epoch.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_Delta">Delta</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>sign: u64</code>
</dt>
<dd>
 Whether X > Y, Y > X or X = Y
</dd>
<dt>
<code>value: u64</code>
</dt>
<dd>
 The cumulative difference in X vs Y
</dd>
</dl>


</details>

<a name="0x1_liquidity_pool_LiquidityPoolEvents"></a>

## Resource `LiquidityPoolEvents`

Liquidity pool events.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a>&lt;X, Y, Curve&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>pool_created_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_PoolCreatedEvent">liquidity_pool::PoolCreatedEvent</a>&lt;X, Y, Curve&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>liquidity_added_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityAddedEvent">liquidity_pool::LiquidityAddedEvent</a>&lt;X, Y, Curve&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>liquidity_removed_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityRemovedEvent">liquidity_pool::LiquidityRemovedEvent</a>&lt;X, Y, Curve&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>swap_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_SwapEvent">liquidity_pool::SwapEvent</a>&lt;X, Y, Curve&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>oracle_update_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_OracleUpdateEvent">liquidity_pool::OracleUpdateEvent</a>&lt;X, Y, Curve&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_liquidity_pool_PoolCreatedEvent"></a>

## Struct `PoolCreatedEvent`

A new liquidity pool has been created.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_PoolCreatedEvent">PoolCreatedEvent</a>&lt;X, Y, Curve&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_liquidity_pool_LiquidityAddedEvent"></a>

## Struct `LiquidityAddedEvent`

Liquidity was added to an existing pool.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityAddedEvent">LiquidityAddedEvent</a>&lt;X, Y, Curve&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>added_x_val: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>added_y_val: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lp_tokens_received: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_liquidity_pool_LiquidityRemovedEvent"></a>

## Struct `LiquidityRemovedEvent`

Liquidity was removed from an existing pool.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityRemovedEvent">LiquidityRemovedEvent</a>&lt;X, Y, Curve&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>returned_x_val: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>returned_y_val: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lp_tokens_burned: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_liquidity_pool_SwapEvent"></a>

## Struct `SwapEvent`

A swap was made in a liquidity pool.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_SwapEvent">SwapEvent</a>&lt;X, Y, Curve&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>x_in: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>x_out: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>y_in: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>y_out: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_liquidity_pool_OracleUpdateEvent"></a>

## Struct `OracleUpdateEvent`

The cumulative price oracle was updated.


<pre><code><b>struct</b> <a href="liquidity_pool.md#0x1_liquidity_pool_OracleUpdateEvent">OracleUpdateEvent</a>&lt;X, Y, Curve&gt; <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>last_price_x_cumulative: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>last_price_y_cumulative: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_samples: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_twap_x: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>epoch_twap_y: u128</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_liquidity_pool_EINVALID_CURVE"></a>

This error should never occur.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_CURVE">EINVALID_CURVE</a>: u64 = 7;
</code></pre>



<a name="0x1_liquidity_pool_DELTA_EQUAL"></a>

Delta zero


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_DELTA_EQUAL">DELTA_EQUAL</a>: u64 = 0;
</code></pre>



<a name="0x1_liquidity_pool_DELTA_NEGATIVE"></a>

Delta negative sign


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_DELTA_NEGATIVE">DELTA_NEGATIVE</a>: u64 = 2;
</code></pre>



<a name="0x1_liquidity_pool_DELTA_POSITIVE"></a>

Delta positive sign


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_DELTA_POSITIVE">DELTA_POSITIVE</a>: u64 = 1;
</code></pre>



<a name="0x1_liquidity_pool_EINSUFFICIENT_INITIAL_LIQUIDITY"></a>

When not enough liquidity is minted.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EINSUFFICIENT_INITIAL_LIQUIDITY">EINSUFFICIENT_INITIAL_LIQUIDITY</a>: u64 = 3;
</code></pre>



<a name="0x1_liquidity_pool_EINSUFFICIENT_LIQUIDITY"></a>

When not enough liquidity is minted.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EINSUFFICIENT_LIQUIDITY">EINSUFFICIENT_LIQUIDITY</a>: u64 = 4;
</code></pre>



<a name="0x1_liquidity_pool_EINVALID_BURN_VALUES"></a>

Incorrect lp coin burn values


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_BURN_VALUES">EINVALID_BURN_VALUES</a>: u64 = 8;
</code></pre>



<a name="0x1_liquidity_pool_EINVALID_ORDERING"></a>

When coins used to create pair have the wrong ordering.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>: u64 = 1;
</code></pre>



<a name="0x1_liquidity_pool_EINVALID_SWAP"></a>

Triggered by a swap which causes liquidity to decrease.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_SWAP">EINVALID_SWAP</a>: u64 = 6;
</code></pre>



<a name="0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST"></a>

When pool doesn't exists for pair.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>: u64 = 9;
</code></pre>



<a name="0x1_liquidity_pool_EPOOL_EXISTS"></a>

A liquidity pool already exists for this pair.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_EXISTS">EPOOL_EXISTS</a>: u64 = 2;
</code></pre>



<a name="0x1_liquidity_pool_EZERO_COIN_IN"></a>

Supplied X and Y for a swap was equal to zero.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EZERO_COIN_IN">EZERO_COIN_IN</a>: u64 = 5;
</code></pre>



<a name="0x1_liquidity_pool_MINIMUM_LIQUIDITY"></a>

Minimum liquidity.


<pre><code><b>const</b> <a href="liquidity_pool.md#0x1_liquidity_pool_MINIMUM_LIQUIDITY">MINIMUM_LIQUIDITY</a>: u64 = 1000;
</code></pre>



<a name="0x1_liquidity_pool_get_delta_sign"></a>

## Function `get_delta_sign`



<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_delta_sign">get_delta_sign</a>(delta: &<a href="liquidity_pool.md#0x1_liquidity_pool_Delta">liquidity_pool::Delta</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_delta_sign">get_delta_sign</a>(delta: &<a href="liquidity_pool.md#0x1_liquidity_pool_Delta">Delta</a>): u64 {
	delta.sign
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_get_delta_value"></a>

## Function `get_delta_value`



<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_delta_value">get_delta_value</a>(delta: &<a href="liquidity_pool.md#0x1_liquidity_pool_Delta">liquidity_pool::Delta</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_delta_value">get_delta_value</a>(delta: &<a href="liquidity_pool.md#0x1_liquidity_pool_Delta">Delta</a>): u64 {
	delta.value
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_register"></a>

## Function `register`

Register a liquidity pool for pair <code>X:Y</code>. This function is only callable by the <code>arx</code> account.


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_register">register</a>&lt;X, Y, Curve&gt;(<a href="arx_account.md#0x1_arx_account">arx_account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_register">register</a>&lt;X, Y, Curve&gt;(<a href="arx_account.md#0x1_arx_account">arx_account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>) {
	// Ensure only the arx <a href="account.md#0x1_account">account</a> at <a href="genesis.md#0x1_genesis">genesis</a> or subsequently <a href="governance.md#0x1_governance">governance</a> can register a new pool.
	<a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>);

	// Ensure <a href="coin.md#0x1_coin">coin</a> types are initialized a priori.
	<a href="coin_type.md#0x1_coin_type_assert_coin_initialized">coin_type::assert_coin_initialized</a>&lt;X&gt;();
	<a href="coin_type.md#0x1_coin_type_assert_coin_initialized">coin_type::assert_coin_initialized</a>&lt;Y&gt;();

	// Ensure pair order correctness.
	<b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);

	// Ensure valid curve.
	<a href="../../std/doc/curves.md#0x1_curves_assert_valid_curve">curves::assert_valid_curve</a>&lt;Curve&gt;();

	// Ensure the liquidity pool does not already exist.
	<b>assert</b>!(!<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_EXISTS">EPOOL_EXISTS</a>);

	<b>let</b> (lp_name, lp_symbol) = <a href="coin_type.md#0x1_coin_type_generate_lp_name_and_symbol">coin_type::generate_lp_name_and_symbol</a>&lt;X, Y, Curve&gt;();
	<b>let</b> (lp_burn_cap, lp_freeze_cap, lp_mint_cap) =
	    <a href="coin.md#0x1_coin_initialize">coin::initialize</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">LP</a>&lt;X, Y, Curve&gt;&gt;(
		<a href="arx_account.md#0x1_arx_account">arx_account</a>,
		lp_name,
		lp_symbol,
		6,
		<b>true</b>
	    );
	<a href="coin.md#0x1_coin_destroy_freeze_cap">coin::destroy_freeze_cap</a>(lp_freeze_cap);

	<b>let</b> x_scale = 0;
	<b>let</b> y_scale = 0;

	<b>if</b> (<a href="../../std/doc/curves.md#0x1_curves_is_stable">curves::is_stable</a>&lt;Curve&gt;()) {
	    x_scale = <a href="../../std/doc/math64.md#0x1_math64_pow_10">math64::pow_10</a>(<a href="coin.md#0x1_coin_decimals">coin::decimals</a>&lt;X&gt;());
	    y_scale = <a href="../../std/doc/math64.md#0x1_math64_pow_10">math64::pow_10</a>(<a href="coin.md#0x1_coin_decimals">coin::decimals</a>&lt;Y&gt;());
	};

	<b>let</b> pool = <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt; {
	    coin_x_reserve: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;X&gt;(),
	    coin_y_reserve: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;Y&gt;(),
	    last_epoch_timestamp: <a href="reconfiguration.md#0x1_reconfiguration_last_reconfiguration_time">reconfiguration::last_reconfiguration_time</a>(),
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
	<b>move_to</b>(<a href="arx_account.md#0x1_arx_account">arx_account</a>, pool);

	<b>let</b> lp_events = <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a>&lt;X, Y, Curve&gt; {
        pool_created_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>),
        liquidity_added_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>),
        liquidity_removed_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>),
        swap_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>),
        oracle_update_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>),
	};
	<a href="event.md#0x1_event_emit_event">event::emit_event</a>(
	    &<b>mut</b> lp_events.pool_created_events,
	    <a href="liquidity_pool.md#0x1_liquidity_pool_PoolCreatedEvent">PoolCreatedEvent</a>&lt;X, Y, Curve&gt; {},
	);
	<b>move_to</b>(<a href="arx_account.md#0x1_arx_account">arx_account</a>, lp_events);
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_mint"></a>

## Function `mint`

Mint new liquidity. Permissionless.
* <code>coin_x</code> - coin X to add to the liquidity reserves.
* <code>coin_y</code> - coin Y to add to the liquidity reserves.
Returns LP coins: <code>Coin&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">LP</a>&lt;X, Y, Curve&gt;&gt;</code>.


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_mint">mint</a>&lt;X, Y, Curve&gt;(coin_x: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;X&gt;, coin_y: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;Y&gt;): <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">liquidity_pool::LP</a>&lt;X, Y, Curve&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_mint">mint</a>&lt;X, Y, Curve&gt;(coin_x: Coin&lt;X&gt;, coin_y: Coin&lt;Y&gt;): Coin&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">LP</a>&lt;X, Y, Curve&gt;&gt;
	<b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>, <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a>
{
	<b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
	<b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

	<b>let</b> lp_coins_total = <a href="coin_type.md#0x1_coin_type_supply">coin_type::supply</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">LP</a>&lt;X, Y, Curve&gt;&gt;();

	<b>let</b> pool = <b>borrow_global_mut</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	<b>let</b> x_reserve_size = <a href="coin.md#0x1_coin_value">coin::value</a>(&pool.coin_x_reserve);
	<b>let</b> y_reserve_size = <a href="coin.md#0x1_coin_value">coin::value</a>(&pool.coin_y_reserve);

	<b>let</b> x_provided_val = <a href="coin.md#0x1_coin_value">coin::value</a>&lt;X&gt;(&coin_x);
	<b>let</b> y_provided_val = <a href="coin.md#0x1_coin_value">coin::value</a>&lt;Y&gt;(&coin_y);

	<b>let</b> provided_liq = <b>if</b> (lp_coins_total == 0) {
	    <b>let</b> initial_liq = <a href="../../std/doc/math128.md#0x1_math128_sqrt">math128::sqrt</a>(<a href="../../std/doc/math64.md#0x1_math64_mul_to_u128">math64::mul_to_u128</a>(x_provided_val, y_provided_val));
	    <b>assert</b>!(initial_liq &gt; <a href="liquidity_pool.md#0x1_liquidity_pool_MINIMUM_LIQUIDITY">MINIMUM_LIQUIDITY</a>, <a href="liquidity_pool.md#0x1_liquidity_pool_EINSUFFICIENT_INITIAL_LIQUIDITY">EINSUFFICIENT_INITIAL_LIQUIDITY</a>);
	    initial_liq - <a href="liquidity_pool.md#0x1_liquidity_pool_MINIMUM_LIQUIDITY">MINIMUM_LIQUIDITY</a>
	} <b>else</b> {
	    <b>let</b> x_liq = <a href="../../std/doc/math128.md#0x1_math128_mul_div">math128::mul_div</a>(
		(x_provided_val <b>as</b> u128), lp_coins_total, (x_reserve_size <b>as</b> u128)
	    );
	    <b>let</b> y_liq = <a href="../../std/doc/math128.md#0x1_math128_mul_div">math128::mul_div</a>(
		(y_provided_val <b>as</b> u128), lp_coins_total, (y_reserve_size <b>as</b> u128)
	    );
	    <b>if</b> (x_liq &lt; y_liq) {
		x_liq
	    } <b>else</b> {
		y_liq
	    }
	};
	<b>assert</b>!(provided_liq &gt; 0, <a href="liquidity_pool.md#0x1_liquidity_pool_EINSUFFICIENT_LIQUIDITY">EINSUFFICIENT_LIQUIDITY</a>);

	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> pool.coin_x_reserve, coin_x);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> pool.coin_y_reserve, coin_y);

	<b>let</b> lp_coins = <a href="coin.md#0x1_coin_mint">coin::mint</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">LP</a>&lt;X, Y, Curve&gt;&gt;(provided_liq, &pool.lp_mint_cap);

	<a href="liquidity_pool.md#0x1_liquidity_pool_update_oracle">update_oracle</a>&lt;X, Y, Curve&gt;(pool, x_reserve_size, y_reserve_size);

	<b>let</b> lp_events = <b>borrow_global_mut</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	<a href="event.md#0x1_event_emit_event">event::emit_event</a>(
	    &<b>mut</b> lp_events.liquidity_added_events,
	    <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityAddedEvent">LiquidityAddedEvent</a>&lt;X, Y, Curve&gt; {
		added_x_val: x_provided_val,
		added_y_val: y_provided_val,
		lp_tokens_received: provided_liq
	    }
	);

	lp_coins
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_burn"></a>

## Function `burn`

Burn liquidity coins (LP) and get back X and Y from its reserves. Permissionless.


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_burn">burn</a>&lt;X, Y, Curve&gt;(lp_coins: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">liquidity_pool::LP</a>&lt;X, Y, Curve&gt;&gt;): (<a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;X&gt;, <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;Y&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_burn">burn</a>&lt;X, Y, Curve&gt;(lp_coins: Coin&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">LP</a>&lt;X, Y, Curve&gt;&gt;): (Coin&lt;X&gt;, Coin&lt;Y&gt;)
<b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>, <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a> {
	<b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
	<b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

	<b>let</b> burned_lp_coins_val = <a href="coin.md#0x1_coin_value">coin::value</a>(&lp_coins);

	<b>let</b> pool = <b>borrow_global_mut</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);

	<b>let</b> lp_coins_total = <a href="coin_type.md#0x1_coin_type_supply">coin_type::supply</a>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LP">LP</a>&lt;X, Y, Curve&gt;&gt;();
	<b>let</b> x_reserve_val = <a href="coin.md#0x1_coin_value">coin::value</a>(&pool.coin_x_reserve);
	<b>let</b> y_reserve_val = <a href="coin.md#0x1_coin_value">coin::value</a>(&pool.coin_y_reserve);

	// Compute x, y <a href="coin.md#0x1_coin">coin</a> values for provided lp_coins value
	<b>let</b> x_to_return_val = <a href="../../std/doc/math128.md#0x1_math128_mul_div">math128::mul_div</a>((burned_lp_coins_val <b>as</b> u128), (x_reserve_val <b>as</b> u128), lp_coins_total);
	<b>let</b> y_to_return_val = <a href="../../std/doc/math128.md#0x1_math128_mul_div">math128::mul_div</a>((burned_lp_coins_val <b>as</b> u128), (y_reserve_val <b>as</b> u128), lp_coins_total);
	<b>assert</b>!(x_to_return_val &gt; 0 && y_to_return_val &gt; 0, <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_BURN_VALUES">EINVALID_BURN_VALUES</a>);

	// Withdraw values from reserves
	<b>let</b> x_coin_to_return = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> pool.coin_x_reserve, x_to_return_val);
	<b>let</b> y_coin_to_return = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> pool.coin_y_reserve, y_to_return_val);

	<a href="liquidity_pool.md#0x1_liquidity_pool_update_oracle">update_oracle</a>&lt;X, Y, Curve&gt;(pool, x_reserve_val, y_reserve_val);
	<a href="coin.md#0x1_coin_burn">coin::burn</a>(lp_coins, &pool.lp_burn_cap);

	<b>let</b> lp_events = <b>borrow_global_mut</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	<a href="event.md#0x1_event_emit_event">event::emit_event</a>(
	    &<b>mut</b> lp_events.liquidity_removed_events,
	    <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityRemovedEvent">LiquidityRemovedEvent</a>&lt;X, Y, Curve&gt; {
		returned_x_val: x_to_return_val,
		returned_y_val: y_to_return_val,
		lp_tokens_burned: burned_lp_coins_val,
	    });

	(x_coin_to_return, y_coin_to_return)
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_swap"></a>

## Function `swap`

Swap coins (may swap both x and y at the same time). Permissionless.


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_swap">swap</a>&lt;X, Y, Curve&gt;(x_in: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;X&gt;, x_out: u64, y_in: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;Y&gt;, y_out: u64): (<a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;X&gt;, <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;Y&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_swap">swap</a>&lt;X, Y, Curve&gt;(
	x_in: Coin&lt;X&gt;,
	x_out: u64,
	y_in: Coin&lt;Y&gt;,
	y_out: u64
): (Coin&lt;X&gt;, Coin&lt;Y&gt;) <b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>, <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a> {
	<b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
	<b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

	<b>let</b> x_in_val = <a href="coin.md#0x1_coin_value">coin::value</a>(&x_in);
	<b>let</b> y_in_val = <a href="coin.md#0x1_coin_value">coin::value</a>(&y_in);

	<b>assert</b>!(x_in_val &gt; 0 || y_in_val &gt; 0, <a href="liquidity_pool.md#0x1_liquidity_pool_EZERO_COIN_IN">EZERO_COIN_IN</a>);

	<b>let</b> pool = <b>borrow_global_mut</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	<b>let</b> x_reserve_size = <a href="coin.md#0x1_coin_value">coin::value</a>(&pool.coin_x_reserve);
	<b>let</b> y_reserve_size = <a href="coin.md#0x1_coin_value">coin::value</a>(&pool.coin_y_reserve);

	// Deposit new coins in the liquidity pool.
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> pool.coin_x_reserve, x_in);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> pool.coin_y_reserve, y_in);

	// Withdraw expected amount from reserves.
	<b>let</b> x_swapped = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> pool.coin_x_reserve, x_out);
	<b>let</b> y_swapped = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> pool.coin_y_reserve, y_out);

	// Ensure the lp_value of the pool hasn't decreased.
	<a href="liquidity_pool.md#0x1_liquidity_pool_assert_lp_value_increase">assert_lp_value_increase</a>&lt;Curve&gt;(
	    pool.x_scale,
	    pool.y_scale,
	    (x_reserve_size <b>as</b> u128),
	    (y_reserve_size <b>as</b> u128),
	    (<a href="coin.md#0x1_coin_value">coin::value</a>(&pool.coin_x_reserve) <b>as</b> u128),
	    (<a href="coin.md#0x1_coin_value">coin::value</a>(&pool.coin_y_reserve) <b>as</b> u128)
	);

	<a href="liquidity_pool.md#0x1_liquidity_pool_update_oracle">update_oracle</a>&lt;X, Y, Curve&gt;(pool, x_reserve_size, y_reserve_size);

	<b>let</b> lp_events = <b>borrow_global_mut</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	<a href="event.md#0x1_event_emit_event">event::emit_event</a>(
	    &<b>mut</b> lp_events.swap_events,
	    <a href="liquidity_pool.md#0x1_liquidity_pool_SwapEvent">SwapEvent</a>&lt;X, Y, Curve&gt; {
		x_in: x_in_val,
		y_in: y_in_val,
		x_out,
		y_out,
	    });

	(x_swapped, y_swapped)
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_update_oracle"></a>

## Function `update_oracle`

Update the cumulative prices (decentralised price oracle).


<pre><code><b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_update_oracle">update_oracle</a>&lt;X, Y, Curve&gt;(pool: &<b>mut</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">liquidity_pool::LiquidityPool</a>&lt;X, Y, Curve&gt;, x_reserve: u64, y_reserve: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_update_oracle">update_oracle</a>&lt;X, Y, Curve&gt;(
	pool: &<b>mut</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;,
	x_reserve: u64,
	y_reserve: u64
) <b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a> {
	<b>let</b> last_epoch_timestamp = <a href="reconfiguration.md#0x1_reconfiguration_last_reconfiguration_time">reconfiguration::last_reconfiguration_time</a>();
	<b>if</b> (last_epoch_timestamp &gt; pool.last_epoch_timestamp) {
	    // Reset the number of time samples taken <b>to</b> 0.
	    pool.epoch_samples = 0;
	    // Set the pools last epoch <a href="timestamp.md#0x1_timestamp">timestamp</a> <b>to</b> the new epoch.
	    pool.last_epoch_timestamp = last_epoch_timestamp;
	};

	<b>let</b> last_block_timestamp = pool.last_block_timestamp;
	<b>let</b> block_timestamp = <a href="timestamp.md#0x1_timestamp_now_seconds">timestamp::now_seconds</a>();
	<b>let</b> time_elapsed = ((block_timestamp - last_block_timestamp) <b>as</b> u128);
	<b>if</b> (time_elapsed &gt; 0 && x_reserve != 0 && y_reserve != 0) {
	    // If the number of epoch samples is 0, then the pools last cumulative price is reset.
	    // Note that this is done after checking that a new sample can be taken since otherwise the
	    // last cumulative price will be 0 until a next successful oracle <b>update</b> is initiated.
	    // This also makes it less likely that there will be a price overflow when computing the
	    // cumulative price.
	    <b>if</b> (pool.epoch_samples == 0) {
		pool.last_x_reserve_cumulative = 0;
		pool.last_y_reserve_cumulative = 0;
		pool.last_price_x_cumulative = 0;
		pool.last_price_y_cumulative = 0;
	    };

	    <b>let</b> last_price_x_cumulative =
		<a href="../../std/doc/uq64x64.md#0x1_uq64x64_to_u128">uq64x64::to_u128</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(y_reserve, x_reserve)) * time_elapsed;
	    <b>let</b> last_price_y_cumulative =
		<a href="../../std/doc/uq64x64.md#0x1_uq64x64_to_u128">uq64x64::to_u128</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(x_reserve, y_reserve)) * time_elapsed;
	    pool.last_price_x_cumulative =
		<a href="../../std/doc/math128.md#0x1_math128_overflow_add">math128::overflow_add</a>(pool.last_price_x_cumulative, last_price_x_cumulative);
	    pool.last_price_y_cumulative =
		<a href="../../std/doc/math128.md#0x1_math128_overflow_add">math128::overflow_add</a>(pool.last_price_y_cumulative, last_price_y_cumulative);

	    <b>let</b> last_x_reserve_cumulative = (x_reserve <b>as</b> u128) * time_elapsed;
	    <b>let</b> last_y_reserve_cumulative = (y_reserve <b>as</b> u128) * time_elapsed;
	    pool.last_x_reserve_cumulative =
		<a href="../../std/doc/math128.md#0x1_math128_overflow_add">math128::overflow_add</a>(pool.last_x_reserve_cumulative, last_x_reserve_cumulative);
	    pool.last_y_reserve_cumulative =
		<a href="../../std/doc/math128.md#0x1_math128_overflow_add">math128::overflow_add</a>(pool.last_y_reserve_cumulative, last_y_reserve_cumulative);

	    pool.epoch_samples = pool.epoch_samples + 1;
	    pool.epoch_twap_x = pool.last_price_x_cumulative / pool.epoch_samples;
	    pool.epoch_twap_y = pool.last_price_y_cumulative / pool.epoch_samples;
	    pool.epoch_twar_x = pool.last_x_reserve_cumulative / pool.epoch_samples;
	    pool.epoch_twar_y = pool.last_y_reserve_cumulative / pool.epoch_samples;

	    <b>let</b> lp_events = <b>borrow_global_mut</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPoolEvents">LiquidityPoolEvents</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	    <a href="event.md#0x1_event_emit_event">event::emit_event</a>(
		&<b>mut</b> lp_events.oracle_update_events,
		<a href="liquidity_pool.md#0x1_liquidity_pool_OracleUpdateEvent">OracleUpdateEvent</a>&lt;X, Y, Curve&gt; {
		    last_price_x_cumulative: pool.last_price_x_cumulative,
		    last_price_y_cumulative: pool.last_price_y_cumulative,
		    epoch_samples: pool.epoch_samples,
		    epoch_twap_x: pool.epoch_twap_x,
		    epoch_twap_y: pool.epoch_twap_y,
		});
	};
	pool.last_block_timestamp = block_timestamp;
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_get_last_epoch_delta"></a>

## Function `get_last_epoch_delta`

Get the time weighted average excess / shortage of <code>X</code> relative to <code>Y</code>.


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_last_epoch_delta">get_last_epoch_delta</a>&lt;X, Y, Curve&gt;(): <a href="liquidity_pool.md#0x1_liquidity_pool_Delta">liquidity_pool::Delta</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_last_epoch_delta">get_last_epoch_delta</a>&lt;X, Y, Curve&gt;(): <a href="liquidity_pool.md#0x1_liquidity_pool_Delta">Delta</a> <b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a> {
	<b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
	<b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

	<b>let</b> pool = <b>borrow_global</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);

	// If there is an excess of X in reserves then the sign is negative
	<b>if</b> (pool.epoch_twar_x &gt; pool.epoch_twar_y) {
	    <a href="liquidity_pool.md#0x1_liquidity_pool_Delta">Delta</a> { sign: <a href="liquidity_pool.md#0x1_liquidity_pool_DELTA_NEGATIVE">DELTA_NEGATIVE</a>, value: ((pool.epoch_twar_x - pool.epoch_twar_y) <b>as</b> u64) }
	} <b>else</b> <b>if</b> (pool.epoch_twar_y &gt; pool.epoch_twar_x) {
	    // If there is a shortage of X in reserves then the sign is positive
	    <a href="liquidity_pool.md#0x1_liquidity_pool_Delta">Delta</a> { sign: <a href="liquidity_pool.md#0x1_liquidity_pool_DELTA_POSITIVE">DELTA_POSITIVE</a>, value: ((pool.epoch_twar_y - pool.epoch_twar_x) <b>as</b> u64) }
	} <b>else</b> {
	    // Otherwise sign is equal
	    <a href="liquidity_pool.md#0x1_liquidity_pool_Delta">Delta</a> { sign: <a href="liquidity_pool.md#0x1_liquidity_pool_DELTA_EQUAL">DELTA_EQUAL</a>, value: 0 }
	}
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_assert_lp_value_increase"></a>

## Function `assert_lp_value_increase`



<pre><code><b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_assert_lp_value_increase">assert_lp_value_increase</a>&lt;Curve&gt;(x_scale: u64, y_scale: u64, x_res: u128, y_res: u128, new_x_res: u128, new_y_res: u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_assert_lp_value_increase">assert_lp_value_increase</a>&lt;Curve&gt;(
	x_scale: u64,
	y_scale: u64,
	x_res: u128,
	y_res: u128,
	new_x_res: u128,
	new_y_res: u128
) {
	<b>if</b> (<a href="../../std/doc/curves.md#0x1_curves_is_stable">curves::is_stable</a>&lt;Curve&gt;()) {
	    <b>let</b> lp_value_before_swap = <a href="../../std/doc/stable_curve.md#0x1_stable_curve_lp_value">stable_curve::lp_value</a>(x_res, x_scale, y_res, y_scale);
	    <b>let</b> lp_value_after_swap = <a href="../../std/doc/stable_curve.md#0x1_stable_curve_lp_value">stable_curve::lp_value</a>(new_x_res, x_scale, new_y_res, y_scale);
	    <b>let</b> cmp = <a href="../../std/doc/u256.md#0x1_u256_compare">u256::compare</a>(&lp_value_after_swap, &lp_value_before_swap);
	    <b>assert</b>!(cmp == 2, <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_SWAP">EINVALID_SWAP</a>);
	} <b>else</b> <b>if</b> (<a href="../../std/doc/curves.md#0x1_curves_is_uncorrelated">curves::is_uncorrelated</a>&lt;Curve&gt;()) {
	    <b>let</b> lp_value_before_swap = <a href="../../std/doc/u256.md#0x1_u256_from_u128">u256::from_u128</a>(x_res * y_res);
	    <b>let</b> lp_value_after_swap = <a href="../../std/doc/u256.md#0x1_u256_mul">u256::mul</a>(
		<a href="../../std/doc/u256.md#0x1_u256_from_u128">u256::from_u128</a>(new_x_res),
		<a href="../../std/doc/u256.md#0x1_u256_from_u128">u256::from_u128</a>(new_y_res)
	    );
	    <b>let</b> cmp = <a href="../../std/doc/u256.md#0x1_u256_compare">u256::compare</a>(&lp_value_after_swap, &lp_value_before_swap);
	    <b>assert</b>!(cmp == 2, <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_SWAP">EINVALID_SWAP</a>);
	} <b>else</b> {
	    <b>abort</b> <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_CURVE">EINVALID_CURVE</a>
	};
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_get_reserve_values"></a>

## Function `get_reserve_values`

Get the reserves of a pool.


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_reserve_values">get_reserve_values</a>&lt;X, Y, Curve&gt;(): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_reserve_values">get_reserve_values</a>&lt;X, Y, Curve&gt;(): (u64, u64)
	<b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a> {
    <b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
    <b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

    <b>let</b> <a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a> = <b>borrow_global</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);
    <b>let</b> x_reserve = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.coin_x_reserve);
    <b>let</b> y_reserve = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.coin_y_reserve);

    (x_reserve, y_reserve)
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_get_decimals_scales"></a>

## Function `get_decimals_scales`

Get decimals scales (10^X decimals, 10^Y decimals) for stable curve.
For uncorrelated curve would return just zeros.


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_decimals_scales">get_decimals_scales</a>&lt;X, Y, Curve&gt;(): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_decimals_scales">get_decimals_scales</a>&lt;X, Y, Curve&gt;(): (u64, u64) <b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a> {
    <b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
    <b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

    <b>let</b> pool = <b>borrow_global</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);
    (pool.x_scale, pool.y_scale)
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_get_cumulative_prices"></a>

## Function `get_cumulative_prices`

Get the current cumulative prices of <code>X</code> and <code>Y</code>.


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_cumulative_prices">get_cumulative_prices</a>&lt;X, Y, Curve&gt;(): (u128, u128, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_cumulative_prices">get_cumulative_prices</a>&lt;X, Y, Curve&gt;(): (u128, u128, u64)
	<b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>
{
	<b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
	<b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

	<b>let</b> <a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a> = <b>borrow_global</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	<b>let</b> last_price_x_cumulative = *&<a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.last_price_x_cumulative;
	<b>let</b> last_price_y_cumulative = *&<a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.last_price_y_cumulative;
	<b>let</b> last_block_timestamp = <a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.last_block_timestamp;

	(last_price_x_cumulative, last_price_y_cumulative, last_block_timestamp)
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_get_epoch_twap"></a>

## Function `get_epoch_twap`



<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_epoch_twap">get_epoch_twap</a>&lt;X, Y, Curve&gt;(): (u128, u128, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_epoch_twap">get_epoch_twap</a>&lt;X, Y, Curve&gt;(): (u128, u128, u64)
	<b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>
{
	<b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
	<b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

	<b>let</b> <a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a> = <b>borrow_global</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	<b>let</b> epoch_twap_x = *&<a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.epoch_twap_x;
	<b>let</b> epoch_twap_y = *&<a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.epoch_twap_y;
	<b>let</b> last_epoch_timestamp = <a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.last_block_timestamp;

	(epoch_twap_x, epoch_twap_y, last_epoch_timestamp)
}
</code></pre>



</details>

<a name="0x1_liquidity_pool_get_epoch_twar"></a>

## Function `get_epoch_twar`



<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_epoch_twar">get_epoch_twar</a>&lt;X, Y, Curve&gt;(): (u128, u128)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_pool.md#0x1_liquidity_pool_get_epoch_twar">get_epoch_twar</a>&lt;X, Y, Curve&gt;(): (u128, u128)
	<b>acquires</b> <a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>
{
	<b>assert</b>!(<a href="coin_type.md#0x1_coin_type_preserves_ordering">coin_type::preserves_ordering</a>&lt;X, Y&gt;(), <a href="liquidity_pool.md#0x1_liquidity_pool_EINVALID_ORDERING">EINVALID_ORDERING</a>);
	<b>assert</b>!(<b>exists</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx), <a href="liquidity_pool.md#0x1_liquidity_pool_EPOOL_DOES_NOT_EXIST">EPOOL_DOES_NOT_EXIST</a>);

	<b>let</b> <a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a> = <b>borrow_global</b>&lt;<a href="liquidity_pool.md#0x1_liquidity_pool_LiquidityPool">LiquidityPool</a>&lt;X, Y, Curve&gt;&gt;(@arx);
	<b>let</b> epoch_twar_x = *&<a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.epoch_twar_x;
	<b>let</b> epoch_twar_y = *&<a href="liquidity_pool.md#0x1_liquidity_pool">liquidity_pool</a>.epoch_twar_y;
	(epoch_twar_x, epoch_twar_y)
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
