
<a name="0x1_solaris"></a>

# Module `0x1::solaris`



-  [Resource `Solaris`](#0x1_solaris_Solaris)
-  [Resource `SeignorageCapability`](#0x1_solaris_SeignorageCapability)
-  [Constants](#@Constants_0)
-  [Function `store_seignorage_cap`](#0x1_solaris_store_seignorage_cap)
-  [Function `initialize_owner`](#0x1_solaris_initialize_owner)
-  [Function `add_coins`](#0x1_solaris_add_coins)
-  [Function `remove_coins`](#0x1_solaris_remove_coins)
-  [Function `withdraw_coins`](#0x1_solaris_withdraw_coins)
-  [Function `reactivate_coins`](#0x1_solaris_reactivate_coins)
-  [Function `on_subsidialis_update`](#0x1_solaris_on_subsidialis_update)
-  [Function `on_subsidialis_deactivate`](#0x1_solaris_on_subsidialis_deactivate)
-  [Function `get_active_lux_value`](#0x1_solaris_get_active_lux_value)
-  [Function `mint_base_seignorage`](#0x1_solaris_mint_base_seignorage)
-  [Function `assert_exists`](#0x1_solaris_assert_exists)


<pre><code><b>use</b> <a href="coin.md#0x1_coin">0x1::coin</a>;
<b>use</b> <a href="../../std/doc/error.md#0x1_error">0x1::error</a>;
<b>use</b> <a href="forma.md#0x1_forma">0x1::forma</a>;
<b>use</b> <a href="lux_coin.md#0x1_lux_coin">0x1::lux_coin</a>;
<b>use</b> <a href="../../std/doc/math64.md#0x1_math64">0x1::math64</a>;
<b>use</b> <a href="nox_coin.md#0x1_nox_coin">0x1::nox_coin</a>;
<b>use</b> <a href="../../std/doc/signer.md#0x1_signer">0x1::signer</a>;
<b>use</b> <a href="system_addresses.md#0x1_system_addresses">0x1::system_addresses</a>;
<b>use</b> <a href="../../std/doc/uq64x64.md#0x1_uq64x64">0x1::uq64x64</a>;
</code></pre>



<a name="0x1_solaris_Solaris"></a>

## Resource `Solaris`



<pre><code><b>struct</b> <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>owner_address: <b>address</b></code>
</dt>
<dd>
 Address of the owner of the solaris.
</dd>
<dt>
<code>active_lux: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;<a href="lux_coin.md#0x1_lux_coin_LuxCoin">lux_coin::LuxCoin</a>&gt;</code>
</dt>
<dd>
 Active lux.
</dd>
<dt>
<code>pending_active_lux: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;<a href="lux_coin.md#0x1_lux_coin_LuxCoin">lux_coin::LuxCoin</a>&gt;</code>
</dt>
<dd>
 Lux pending activation. Occurs every epoch.
</dd>
<dt>
<code>active_nox: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;<a href="nox_coin.md#0x1_nox_coin_NoxCoin">nox_coin::NoxCoin</a>&gt;</code>
</dt>
<dd>
 Active nox.
</dd>
<dt>
<code>pending_active_nox: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;<a href="nox_coin.md#0x1_nox_coin_NoxCoin">nox_coin::NoxCoin</a>&gt;</code>
</dt>
<dd>
 Nox pending activation. Occurs every epoch where ARX > 1.
</dd>
<dt>
<code>locked_forma: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;CoinType&gt;</code>
</dt>
<dd>
 Locked forma coins.
</dd>
<dt>
<code>pending_unlocked_forma: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;CoinType&gt;</code>
</dt>
<dd>
 Forma coins pending unlock.
</dd>
<dt>
<code>unlocked_forma: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;CoinType&gt;</code>
</dt>
<dd>
 Unlocked forma coins.
</dd>
<dt>
<code>time_remaining: u64</code>
</dt>
<dd>
 The time remaining until the forma coins are withdrawable.
</dd>
</dl>


</details>

<a name="0x1_solaris_SeignorageCapability"></a>

## Resource `SeignorageCapability`

Set during genesis and stored in the @core_resource account.
Allows this module to mint and burn seignorage tokens.


<pre><code><b>struct</b> <a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>lux_mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="lux_coin.md#0x1_lux_coin_LuxCoin">lux_coin::LuxCoin</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>lux_burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="lux_coin.md#0x1_lux_coin_LuxCoin">lux_coin::LuxCoin</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>nox_mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="nox_coin.md#0x1_nox_coin_NoxCoin">nox_coin::NoxCoin</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>nox_burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="nox_coin.md#0x1_nox_coin_NoxCoin">nox_coin::NoxCoin</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_solaris_EEXISTING_SOLARIS"></a>

A solaris for a specified coin type already exists at the supplied address.


<pre><code><b>const</b> <a href="solaris.md#0x1_solaris_EEXISTING_SOLARIS">EEXISTING_SOLARIS</a>: u64 = 2;
</code></pre>



<a name="0x1_solaris_ESOLARIS_NOT_FOUND"></a>

A solaris for a specified coin type was not found at the supplied address.


<pre><code><b>const</b> <a href="solaris.md#0x1_solaris_ESOLARIS_NOT_FOUND">ESOLARIS_NOT_FOUND</a>: u64 = 1;
</code></pre>



<a name="0x1_solaris_store_seignorage_cap"></a>

## Function `store_seignorage_cap`

Allows a module which creates solarii to


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="solaris.md#0x1_solaris_store_seignorage_cap">store_seignorage_cap</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, lux_mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="lux_coin.md#0x1_lux_coin_LuxCoin">lux_coin::LuxCoin</a>&gt;, lux_burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="lux_coin.md#0x1_lux_coin_LuxCoin">lux_coin::LuxCoin</a>&gt;, nox_mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="nox_coin.md#0x1_nox_coin_NoxCoin">nox_coin::NoxCoin</a>&gt;, nox_burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="nox_coin.md#0x1_nox_coin_NoxCoin">nox_coin::NoxCoin</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="solaris.md#0x1_solaris_store_seignorage_cap">store_seignorage_cap</a>(
	arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>,
	lux_mint_cap: MintCapability&lt;LuxCoin&gt;,
	lux_burn_cap: BurnCapability&lt;LuxCoin&gt;,
	nox_mint_cap: MintCapability&lt;NoxCoin&gt;,
	nox_burn_cap: BurnCapability&lt;NoxCoin&gt;,
) {
	<a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);
	<b>move_to</b>(arx, <a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a> {
	    lux_mint_cap, lux_burn_cap, nox_mint_cap, nox_burn_cap,
	});
}
</code></pre>



</details>

<a name="0x1_solaris_initialize_owner"></a>

## Function `initialize_owner`

Initialises a new solaris assigned to the provided owner.


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_initialize_owner">initialize_owner</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_initialize_owner">initialize_owner</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>) {
	// Ensure a <a href="forma.md#0x1_forma">forma</a> <b>exists</b> for this <a href="solaris.md#0x1_solaris">solaris</a>.
	<a href="forma.md#0x1_forma_assert_exists">forma::assert_exists</a>&lt;CoinType&gt;();
	// Ensure a <a href="solaris.md#0x1_solaris">solaris</a> does not already exist for this owner.
	<b>let</b> owner_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);
	<b>assert</b>!(!<b>exists</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(owner_address), <a href="../../std/doc/error.md#0x1_error_already_exists">error::already_exists</a>(<a href="solaris.md#0x1_solaris_EEXISTING_SOLARIS">EEXISTING_SOLARIS</a>));
	// Initialise a new <a href="solaris.md#0x1_solaris">solaris</a> and <b>move</b> <b>to</b> owner.
	<b>move_to</b>(owner, <a href="solaris.md#0x1_solaris_Solaris">Solaris</a> {
	    owner_address,
	    active_lux: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;LuxCoin&gt;(),
	    pending_active_lux: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;LuxCoin&gt;(),
	    active_nox: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;NoxCoin&gt;(),
	    pending_active_nox: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;NoxCoin&gt;(),
	    locked_forma: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;CoinType&gt;(),
	    pending_unlocked_forma: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;CoinType&gt;(),
	    unlocked_forma: <a href="coin.md#0x1_coin_zero">coin::zero</a>&lt;CoinType&gt;(),
	    time_remaining: 0,
	});
}
</code></pre>



</details>

<a name="0x1_solaris_add_coins"></a>

## Function `add_coins`

Add forma coins to an existing solaris. External.


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_add_coins">add_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_add_coins">add_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
	<b>acquires</b> <a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>, <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>
{
	<b>let</b> solaris_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);
	<a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(solaris_address);

	// Withdraw the specified amount of <a href="forma.md#0x1_forma">forma</a> coins from the owners wallet.
	<b>let</b> coins = <a href="coin.md#0x1_coin_withdraw">coin::withdraw</a>&lt;CoinType&gt;(owner, amount);

	// Check that the <a href="coin.md#0x1_coin">coin</a> value is != 0.
	<b>let</b> amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&coins);
	<b>if</b> (amount == 0) {
	    // Otherwise burn the 0 coins.
	    <a href="coin.md#0x1_coin_destroy_zero">coin::destroy_zero</a>(coins);
	    <b>return</b>
	};

	// Store the added coins into the <a href="solaris.md#0x1_solaris">solaris</a>.
	<b>let</b> <a href="solaris.md#0x1_solaris">solaris</a> = <b>borrow_global_mut</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(solaris_address);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>&lt;CoinType&gt;(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.locked_forma, coins);

	// Mint the base seignorage reward for locking <a href="forma.md#0x1_forma">forma</a> coins.
	<a href="solaris.md#0x1_solaris_mint_base_seignorage">mint_base_seignorage</a>&lt;CoinType&gt;(<a href="solaris.md#0x1_solaris">solaris</a>, amount);
}
</code></pre>



</details>

<a name="0x1_solaris_remove_coins"></a>

## Function `remove_coins`

Remove forma coins from an existing solaris. External.


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_remove_coins">remove_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_remove_coins">remove_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
	<b>acquires</b> <a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>, <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>
{
	// Short-circuit <b>if</b> amount <b>to</b> remove is 0 so that no events are emitted.
	<b>if</b> (amount == 0) {
	    <b>return</b>
	};
	
	// Fetch the <a href="solaris.md#0x1_solaris">solaris</a> assigned <b>to</b> the current owner.
	<b>let</b> solaris_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);
	<a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(solaris_address);
	<b>let</b> <a href="solaris.md#0x1_solaris">solaris</a> = <b>borrow_global_mut</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(solaris_address);
	
	// Cap the amount <b>to</b> unlock by the maximum locked <a href="forma.md#0x1_forma">forma</a> coins.
	<b>let</b> locked_amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.locked_forma);
	<b>let</b> remove_amount = <a href="../../std/doc/math64.md#0x1_math64_min">math64::min</a>(amount, locked_amount);
	// Return <b>if</b> the amount is 0.
	<b>if</b> (amount == 0) {
	    <b>return</b>
	};
	// Move locked removed coins <b>to</b> pending unlocked. When the lockup cycle expires they will be
	// moved <b>to</b> unlocked and become withdrawable.
	<b>let</b> removed_coins = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.locked_forma, remove_amount);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>&lt;CoinType&gt;(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.pending_unlocked_forma, removed_coins);

	// Compute (locked_amount / remove_amount) in order <b>to</b> calculate how much seignorage should be
	// burned for unlocking.
	<b>let</b> seignorage_burn_fraction = <a href="../../std/doc/uq64x64.md#0x1_uq64x64_decode">uq64x64::decode</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(locked_amount, remove_amount));

	// Burn a (active_nox_amount / seignorage_burn_fraction) of nox.
	<b>let</b> nox_burn_cap = &<b>borrow_global</b>&lt;<a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>&gt;(@arx).nox_burn_cap;
	<b>let</b> nox_amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.active_nox);
	<b>let</b> nox_burn_amount = <a href="../../std/doc/uq64x64.md#0x1_uq64x64_decode">uq64x64::decode</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(nox_amount, seignorage_burn_fraction));
	<b>let</b> nox_coins = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.active_nox, nox_burn_amount);
	<a href="coin.md#0x1_coin_burn">coin::burn</a>(nox_coins, nox_burn_cap);

	// Burn a (active_lux_amount / seignorage_burn_fraction) of lux.
	<b>let</b> lux_burn_cap = &<b>borrow_global</b>&lt;<a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>&gt;(@arx).lux_burn_cap;
	<b>let</b> lux_amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.active_lux);
	<b>let</b> lux_burn_amount = <a href="../../std/doc/uq64x64.md#0x1_uq64x64_decode">uq64x64::decode</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(lux_amount, seignorage_burn_fraction));
	<b>let</b> lux_coins = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.active_lux, lux_burn_amount);
	<a href="coin.md#0x1_coin_burn">coin::burn</a>(lux_coins, lux_burn_cap);
}
</code></pre>



</details>

<a name="0x1_solaris_withdraw_coins"></a>

## Function `withdraw_coins`

Withdraw unlocked coins from an existing solaris. External.


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_withdraw_coins">withdraw_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
	<b>acquires</b> <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>
{
	// Check that the amount <b>to</b> withdraw != 0, otherwise <b>return</b>.
	<b>if</b> (amount == 0) {
	    <b>return</b>
	};

	// Fetch the <a href="solaris.md#0x1_solaris">solaris</a> assigned <b>to</b> the current owner.
	<b>let</b> solaris_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);
	<a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(solaris_address);
	<b>let</b> <a href="solaris.md#0x1_solaris">solaris</a> = <b>borrow_global_mut</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(solaris_address);

	// Compute the amount <b>to</b> withdraw capped by the unlocked amount.
	<b>let</b> unlocked_amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.unlocked_forma);
	<b>let</b> withdraw_amount = <a href="../../std/doc/math64.md#0x1_math64_min">math64::min</a>(amount, unlocked_amount);
	// Check that the withdrawn amount is non-zero, otherwise <b>return</b>.
	<b>if</b> (withdraw_amount == 0) {
	    <b>return</b>
	};

	// Move unlocked coins <b>to</b> owner.
	<b>let</b> withdrawn_coins = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.unlocked_forma, withdraw_amount);
	<a href="coin.md#0x1_coin_deposit">coin::deposit</a>&lt;CoinType&gt;(<a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner), withdrawn_coins);
}
</code></pre>



</details>

<a name="0x1_solaris_reactivate_coins"></a>

## Function `reactivate_coins`

Reactivate forma coins pending unlock.


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_reactivate_coins">reactivate_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="solaris.md#0x1_solaris_reactivate_coins">reactivate_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
	<b>acquires</b> <a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>, <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>
{
	// Check that the amount <b>to</b> reactivate != 0, otherwise <b>return</b>.
	<b>if</b> (amount == 0) {
	    <b>return</b>
	};

	// Fetch the <a href="solaris.md#0x1_solaris">solaris</a> assigned <b>to</b> the current owner.
	<b>let</b> solaris_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);
	<a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(solaris_address);
	<b>let</b> <a href="solaris.md#0x1_solaris">solaris</a> = <b>borrow_global_mut</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(solaris_address);

	// Compute the amount <b>to</b> reactivate capped by the pending unlocked amount.
	<b>let</b> pending_unlocked_amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.pending_unlocked_forma);
	<b>let</b> reactivate_amount = <a href="../../std/doc/math64.md#0x1_math64_min">math64::min</a>(amount, pending_unlocked_amount);
	// Check that the reactivate amount is non-zero, otherwise <b>return</b>.
	<b>if</b> (reactivate_amount == 0) {
	    <b>return</b>
	};

	// Move pending unlocked <b>to</b> active.
	<b>let</b> reactivated_coins = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.pending_unlocked_forma, reactivate_amount);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>&lt;CoinType&gt;(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.locked_forma, reactivated_coins);

	// Re-assign seignorage <b>to</b> reactivated coins.
	<a href="solaris.md#0x1_solaris_mint_base_seignorage">mint_base_seignorage</a>&lt;CoinType&gt;(<a href="solaris.md#0x1_solaris">solaris</a>, reactivate_amount);
}
</code></pre>



</details>

<a name="0x1_solaris_on_subsidialis_update"></a>

## Function `on_subsidialis_update`

Allocate subsidialis based seignorage rewards. Only called from the subsidialis.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="solaris.md#0x1_solaris_on_subsidialis_update">on_subsidialis_update</a>&lt;CoinType&gt;(solaris_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="solaris.md#0x1_solaris_on_subsidialis_update">on_subsidialis_update</a>&lt;CoinType&gt;(solaris_address: <b>address</b>)
	<b>acquires</b> <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>, <a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>
{
	// Fetch the <a href="solaris.md#0x1_solaris">solaris</a> assigned <b>to</b> the current owner.
	<a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(solaris_address);
	<b>let</b> <a href="solaris.md#0x1_solaris">solaris</a> = <b>borrow_global_mut</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(solaris_address);

	// Pending active nox is moved <b>to</b> active (generated by the moneta)
	<b>let</b> pending_nox_amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.pending_active_nox);
	<b>let</b> pending_nox = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.pending_active_nox, pending_nox_amount);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.active_nox, pending_nox);

	// Pending active lux is moved <b>to</b> active (generated per epoch by held nox)
	<b>let</b> pending_lux_amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.pending_active_lux);
	<b>let</b> pending_lux = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.pending_active_lux, pending_lux_amount);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.active_lux, pending_lux);

	// Each active nox is used <b>to</b> generate 1/10000th of a pending_active lux
	<b>let</b> active_nox_value = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.active_nox);
	<b>let</b> pending_lux_reward = <a href="../../std/doc/uq64x64.md#0x1_uq64x64_decode">uq64x64::decode</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(active_nox_value, 10000));
	<b>let</b> lux_mint_cap = &<b>borrow_global</b>&lt;<a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>&gt;(@arx).lux_mint_cap;
	<b>let</b> lux_reward = <a href="coin.md#0x1_coin_mint">coin::mint</a>(pending_lux_reward, lux_mint_cap);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.pending_active_lux, lux_reward);
}
</code></pre>



</details>

<a name="0x1_solaris_on_subsidialis_deactivate"></a>

## Function `on_subsidialis_deactivate`

Moves pending unlocked forma coins to unlocked. Only called from the subsidialis.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="solaris.md#0x1_solaris_on_subsidialis_deactivate">on_subsidialis_deactivate</a>&lt;CoinType&gt;(solaris_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="solaris.md#0x1_solaris_on_subsidialis_deactivate">on_subsidialis_deactivate</a>&lt;CoinType&gt;(solaris_address: <b>address</b>)
	<b>acquires</b> <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>
{
	// Fetch the <a href="solaris.md#0x1_solaris">solaris</a> assigned <b>to</b> the current owner.
	<a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(solaris_address);
	<b>let</b> <a href="solaris.md#0x1_solaris">solaris</a> = <b>borrow_global_mut</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(solaris_address);

	// Pending unlocked <a href="forma.md#0x1_forma">forma</a> coins are moved <b>to</b> unlocked
	<b>let</b> amount = <a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.pending_unlocked_forma);
	<b>let</b> pending_unlocked_forma = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.pending_unlocked_forma, amount);
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.unlocked_forma, pending_unlocked_forma);
}
</code></pre>



</details>

<a name="0x1_solaris_get_active_lux_value"></a>

## Function `get_active_lux_value`

Gets the active lux value of a solaris.


<pre><code><b>public</b> <b>fun</b> <a href="solaris.md#0x1_solaris_get_active_lux_value">get_active_lux_value</a>&lt;CoinType&gt;(solaris_address: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="solaris.md#0x1_solaris_get_active_lux_value">get_active_lux_value</a>&lt;CoinType&gt;(solaris_address: <b>address</b>): u64
	<b>acquires</b> <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>
{
	<a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(solaris_address);
	<b>let</b> <a href="solaris.md#0x1_solaris">solaris</a> = <b>borrow_global</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(solaris_address);
	<a href="coin.md#0x1_coin_value">coin::value</a>(&<a href="solaris.md#0x1_solaris">solaris</a>.active_lux)
}
</code></pre>



</details>

<a name="0x1_solaris_mint_base_seignorage"></a>

## Function `mint_base_seignorage`

Mint the base seignorage reward for locking forma coins.


<pre><code><b>fun</b> <a href="solaris.md#0x1_solaris_mint_base_seignorage">mint_base_seignorage</a>&lt;CoinType&gt;(<a href="solaris.md#0x1_solaris">solaris</a>: &<b>mut</b> <a href="solaris.md#0x1_solaris_Solaris">solaris::Solaris</a>&lt;CoinType&gt;, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="solaris.md#0x1_solaris_mint_base_seignorage">mint_base_seignorage</a>&lt;CoinType&gt;(<a href="solaris.md#0x1_solaris">solaris</a>: &<b>mut</b> <a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;, amount: u64)
	<b>acquires</b> <a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>
{
	// Mint amount * lux_incentive coins.
	<b>let</b> lux_incentive = <a href="forma.md#0x1_forma_get_lux_incentive">forma::get_lux_incentive</a>&lt;CoinType&gt;();
	<b>let</b> lux_mint_cap = &<b>borrow_global</b>&lt;<a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>&gt;(@arx).lux_mint_cap;
	<b>let</b> lux_coins = <a href="coin.md#0x1_coin_mint">coin::mint</a>(amount * lux_incentive, lux_mint_cap);
	// Store the lux coins in the active lux.
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.active_lux, lux_coins);

	// Mint amount * nox_incentive coins.
	<b>let</b> nox_incentive = <a href="forma.md#0x1_forma_get_nox_incentive">forma::get_nox_incentive</a>&lt;CoinType&gt;();
	<b>let</b> nox_mint_cap = &<b>borrow_global</b>&lt;<a href="solaris.md#0x1_solaris_SeignorageCapability">SeignorageCapability</a>&gt;(@arx).nox_mint_cap;
	<b>let</b> nox_coins = <a href="coin.md#0x1_coin_mint">coin::mint</a>(amount * nox_incentive, nox_mint_cap);
	// Store the nox coins in the active nox.
	<a href="coin.md#0x1_coin_merge">coin::merge</a>(&<b>mut</b> <a href="solaris.md#0x1_solaris">solaris</a>.active_nox, nox_coins);
}
</code></pre>



</details>

<a name="0x1_solaris_assert_exists"></a>

## Function `assert_exists`

Ensures a solaris exists for the supplied coin type at address.


<pre><code><b>public</b> <b>fun</b> <a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(<b>address</b>: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="solaris.md#0x1_solaris_assert_exists">assert_exists</a>&lt;CoinType&gt;(<b>address</b>: <b>address</b>) {
	<b>assert</b>!(<b>exists</b>&lt;<a href="solaris.md#0x1_solaris_Solaris">Solaris</a>&lt;CoinType&gt;&gt;(<b>address</b>), <a href="../../std/doc/error.md#0x1_error_not_found">error::not_found</a>(<a href="solaris.md#0x1_solaris_ESOLARIS_NOT_FOUND">ESOLARIS_NOT_FOUND</a>));
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
