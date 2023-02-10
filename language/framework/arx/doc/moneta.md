
<a name="0x1_moneta"></a>

# Module `0x1::moneta`

The purpose of the moneta is to distribute <code>ARX</code> to members of the subsidialis, the senatus and the
danistae.


-  [Resource `Moneta`](#0x1_moneta_Moneta)
-  [Resource `ArxCoinCapability`](#0x1_moneta_ArxCoinCapability)
-  [Resource `XUSDCoinCapability`](#0x1_moneta_XUSDCoinCapability)
-  [Function `initialize_for_testing`](#0x1_moneta_initialize_for_testing)
-  [Function `on_new_epoch`](#0x1_moneta_on_new_epoch)
-  [Function `calculate_mint_shares`](#0x1_moneta_calculate_mint_shares)
-  [Function `calculate_subsidialis_mints`](#0x1_moneta_calculate_subsidialis_mints)
-  [Function `store_arx_coin_mint_cap`](#0x1_moneta_store_arx_coin_mint_cap)
-  [Function `store_xusd_coin_mint_cap`](#0x1_moneta_store_xusd_coin_mint_cap)


<pre><code><b>use</b> <a href="arx_coin.md#0x1_arx_coin">0x1::arx_coin</a>;
<b>use</b> <a href="coin.md#0x1_coin">0x1::coin</a>;
<b>use</b> <a href="../../std/doc/curves.md#0x1_curves">0x1::curves</a>;
<b>use</b> <a href="delta.md#0x1_delta">0x1::delta</a>;
<b>use</b> <a href="liquidity_pool.md#0x1_liquidity_pool">0x1::liquidity_pool</a>;
<b>use</b> <a href="lp_coin.md#0x1_lp_coin">0x1::lp_coin</a>;
<b>use</b> <a href="subsidialis.md#0x1_subsidialis">0x1::subsidialis</a>;
<b>use</b> <a href="system_addresses.md#0x1_system_addresses">0x1::system_addresses</a>;
<b>use</b> <a href="../../std/doc/uq64x64.md#0x1_uq64x64">0x1::uq64x64</a>;
<b>use</b> <a href="xusd_coin.md#0x1_xusd_coin">0x1::xusd_coin</a>;
</code></pre>



<a name="0x1_moneta_Moneta"></a>

## Resource `Moneta`



<pre><code><b>struct</b> <a href="moneta.md#0x1_moneta_Moneta">Moneta</a> <b>has</b> key
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

<a name="0x1_moneta_ArxCoinCapability"></a>

## Resource `ArxCoinCapability`

The ArxCoinCapability is conferred at genesis and stored in the @core_resouce account.
This allows the <code><a href="moneta.md#0x1_moneta">moneta</a></code> module to mint <code>ARX</code>.


<pre><code><b>struct</b> <a href="moneta.md#0x1_moneta_ArxCoinCapability">ArxCoinCapability</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_moneta_XUSDCoinCapability"></a>

## Resource `XUSDCoinCapability`

The XUSDCoinCapability (only used for minting XUSDCoin whilst testing).


<pre><code><b>struct</b> <a href="moneta.md#0x1_moneta_XUSDCoinCapability">XUSDCoinCapability</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="xusd_coin.md#0x1_xusd_coin_XUSDCoin">xusd_coin::XUSDCoin</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="xusd_coin.md#0x1_xusd_coin_XUSDCoin">xusd_coin::XUSDCoin</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_moneta_initialize_for_testing"></a>

## Function `initialize_for_testing`



<pre><code><b>public</b> <b>fun</b> <a href="moneta.md#0x1_moneta_initialize_for_testing">initialize_for_testing</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="moneta.md#0x1_moneta_initialize_for_testing">initialize_for_testing</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
	<b>acquires</b> <a href="moneta.md#0x1_moneta_ArxCoinCapability">ArxCoinCapability</a>, <a href="moneta.md#0x1_moneta_XUSDCoinCapability">XUSDCoinCapability</a>
{
	<a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);

	// Initialise the monetas price oracle.
	<a href="liquidity_pool.md#0x1_liquidity_pool_register">liquidity_pool::register</a>&lt;ArxCoin, XUSDCoin, Stable&gt;(arx);

	// Mint 1000:1000 ARX against XUSDCoin
	<b>let</b> arx_mint_cap = &<b>borrow_global</b>&lt;<a href="moneta.md#0x1_moneta_ArxCoinCapability">ArxCoinCapability</a>&gt;(@arx).mint_cap;
	<b>let</b> arx_initial_coins = <a href="coin.md#0x1_coin_mint">coin::mint</a>&lt;ArxCoin&gt;(1001, arx_mint_cap);
	<b>let</b> xusd_mint_cap = &<b>borrow_global</b>&lt;<a href="moneta.md#0x1_moneta_XUSDCoinCapability">XUSDCoinCapability</a>&gt;(@arx).mint_cap;
	<b>let</b> xusd_initial_coins = <a href="coin.md#0x1_coin_mint">coin::mint</a>&lt;XUSDCoin&gt;(1001, xusd_mint_cap);
	// Add 1000:1000 <b>to</b> the liquidity pool
	<b>let</b> initial_liquidity =
	    <a href="liquidity_pool.md#0x1_liquidity_pool_mint">liquidity_pool::mint</a>&lt;ArxCoin, XUSDCoin, Stable&gt;(arx_initial_coins, xusd_initial_coins);
	// Burn the `ARX` liquidity tokens, rendering them unusable
	<a href="liquidity_pool.md#0x1_liquidity_pool_burn_destructive">liquidity_pool::burn_destructive</a>&lt;ArxCoin, XUSDCoin, Stable&gt;(initial_liquidity);
}
</code></pre>



</details>

<a name="0x1_moneta_on_new_epoch"></a>

## Function `on_new_epoch`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="moneta.md#0x1_moneta_on_new_epoch">on_new_epoch</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="moneta.md#0x1_moneta_on_new_epoch">on_new_epoch</a>()
	<b>acquires</b> <a href="moneta.md#0x1_moneta_ArxCoinCapability">ArxCoinCapability</a>
{
	// Fetch the Arx <a href="delta.md#0x1_delta">delta</a> for this epoch according <b>to</b> the price oracle.
	<b>let</b> <a href="delta.md#0x1_delta">delta</a> = <a href="liquidity_pool.md#0x1_liquidity_pool_get_last_epoch_delta">liquidity_pool::get_last_epoch_delta</a>&lt;ArxCoin, XUSDCoin, Stable&gt;();
	// If the deltaA is positive &gt;1:
	<b>if</b> (<a href="delta.md#0x1_delta_get_delta_value">delta::get_delta_value</a>(&<a href="delta.md#0x1_delta">delta</a>) == 1) {
	    // Calculate the share of new mints owed <b>to</b> the <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> (TODO: and the <a href="senatus.md#0x1_senatus">senatus</a>).
	    <b>let</b> (subsidialis_share, _daenistae_share) = <a href="moneta.md#0x1_moneta_calculate_mint_shares">calculate_mint_shares</a>(&<a href="delta.md#0x1_delta">delta</a>);
	    // Calculate the share of <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> mints between `ArxCoin` and `LP&lt;..&gt;`.
	    <b>let</b> (subsidialis_arx_mints, subsidialis_lp_mints) =
		<a href="moneta.md#0x1_moneta_calculate_subsidialis_mints">calculate_subsidialis_mints</a>(subsidialis_share);
	    // Mint thew `ARX` and distribute the mints <b>to</b> the <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>
	    <b>let</b> arx_mint_cap = &<b>borrow_global</b>&lt;<a href="moneta.md#0x1_moneta_ArxCoinCapability">ArxCoinCapability</a>&gt;(@arx).mint_cap;
	    <b>let</b> subsidialis_arx_coins = <a href="coin.md#0x1_coin_mint">coin::mint</a>&lt;ArxCoin&gt;(subsidialis_arx_mints, arx_mint_cap);
	    <b>let</b> subsidialis_lp_coins = <a href="coin.md#0x1_coin_mint">coin::mint</a>&lt;ArxCoin&gt;(subsidialis_lp_mints, arx_mint_cap);
	    <a href="subsidialis.md#0x1_subsidialis_distribute_mints">subsidialis::distribute_mints</a>&lt;ArxCoin&gt;(subsidialis_arx_coins);
	    <a href="subsidialis.md#0x1_subsidialis_distribute_mints">subsidialis::distribute_mints</a>&lt;LP&lt;ArxCoin, XUSDCoin, Stable&gt;&gt;(subsidialis_lp_coins);
	    // Assign 50% of mints <b>to</b> the danistae.
	    // <b>let</b> _danistae_mints = <a href="delta.md#0x1_delta_get_delta_value">delta::get_delta_value</a>(&<a href="delta.md#0x1_delta">delta</a>) / 2;
	    // Decrease the nexus interest rate.
	} <b>else</b> <b>if</b> (<a href="delta.md#0x1_delta_get_delta_value">delta::get_delta_value</a>(&<a href="delta.md#0x1_delta">delta</a>) == 2) {
	    // If the deltaA is negative &lt;1:
	    // Offer (-deltaA / 2) aes <b>to</b> the danistae.
	    // Increase the interest rate on bonds according <b>to</b> game theoretic incentives.
	} <b>else</b> {
	    // Do nothing.
	}
}
</code></pre>



</details>

<a name="0x1_moneta_calculate_mint_shares"></a>

## Function `calculate_mint_shares`



<pre><code><b>fun</b> <a href="moneta.md#0x1_moneta_calculate_mint_shares">calculate_mint_shares</a>(<a href="delta.md#0x1_delta">delta</a>: &<a href="delta.md#0x1_delta_Delta">delta::Delta</a>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="moneta.md#0x1_moneta_calculate_mint_shares">calculate_mint_shares</a>(<a href="delta.md#0x1_delta">delta</a>: &Delta): (u64, u64) {
	// TODO: Add <a href="senatus.md#0x1_senatus">senatus</a>
	<b>let</b> subsidialis_share = <a href="delta.md#0x1_delta_get_delta_value">delta::get_delta_value</a>(<a href="delta.md#0x1_delta">delta</a>) / 2;
	<b>let</b> danistae_share = <a href="delta.md#0x1_delta_get_delta_value">delta::get_delta_value</a>(<a href="delta.md#0x1_delta">delta</a>) / 2;
	(subsidialis_share, danistae_share)
}
</code></pre>



</details>

<a name="0x1_moneta_calculate_subsidialis_mints"></a>

## Function `calculate_subsidialis_mints`



<pre><code><b>fun</b> <a href="moneta.md#0x1_moneta_calculate_subsidialis_mints">calculate_subsidialis_mints</a>(share_of_mints: u64): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="moneta.md#0x1_moneta_calculate_subsidialis_mints">calculate_subsidialis_mints</a>(share_of_mints: u64): (u64, u64) {
	// FIXME: This math loses a lot of precision / hacky / erroneous
	<b>let</b> arx_power = (<a href="subsidialis.md#0x1_subsidialis_get_total_active_power">subsidialis::get_total_active_power</a>&lt;ArxCoin&gt;() <b>as</b> u64);
	<b>let</b> lp_power = (<a href="subsidialis.md#0x1_subsidialis_get_total_active_power">subsidialis::get_total_active_power</a>&lt;LP&lt;ArxCoin, XUSDCoin, Stable&gt;&gt;() <b>as</b> u64);
	<b>let</b> combined_power = (((arx_power <b>as</b> u128) + (lp_power <b>as</b> u128)) <b>as</b> u64);
	<b>let</b> arx_power_fraction = <a href="../../std/doc/uq64x64.md#0x1_uq64x64_decode">uq64x64::decode</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(arx_power, combined_power));
	<b>let</b> lp_power_fraction = <a href="../../std/doc/uq64x64.md#0x1_uq64x64_decode">uq64x64::decode</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(lp_power, combined_power));
	<b>let</b> arx_mints = arx_power_fraction * share_of_mints;
	<b>let</b> lp_mints = lp_power_fraction * share_of_mints;
	(arx_mints, lp_mints)
}
</code></pre>



</details>

<a name="0x1_moneta_store_arx_coin_mint_cap"></a>

## Function `store_arx_coin_mint_cap`

This is only called during Genesis, which is where MintCapability<ArxCoin> can be created.
Beyond genesis, no one can create <code>ArxCoin</code> mint/burn capabilities.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="moneta.md#0x1_moneta_store_arx_coin_mint_cap">store_arx_coin_mint_cap</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;, burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="moneta.md#0x1_moneta_store_arx_coin_mint_cap">store_arx_coin_mint_cap</a>(
	arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>,
	mint_cap: MintCapability&lt;ArxCoin&gt;,
	burn_cap: BurnCapability&lt;ArxCoin&gt;
) {
    <a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);
    <b>move_to</b>(arx, <a href="moneta.md#0x1_moneta_ArxCoinCapability">ArxCoinCapability</a> { mint_cap, burn_cap })
}
</code></pre>



</details>

<a name="0x1_moneta_store_xusd_coin_mint_cap"></a>

## Function `store_xusd_coin_mint_cap`

This is only called in test networks, works the same as the arx coin capability.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="moneta.md#0x1_moneta_store_xusd_coin_mint_cap">store_xusd_coin_mint_cap</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, mint_cap: <a href="coin.md#0x1_coin_MintCapability">coin::MintCapability</a>&lt;<a href="xusd_coin.md#0x1_xusd_coin_XUSDCoin">xusd_coin::XUSDCoin</a>&gt;, burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="xusd_coin.md#0x1_xusd_coin_XUSDCoin">xusd_coin::XUSDCoin</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="moneta.md#0x1_moneta_store_xusd_coin_mint_cap">store_xusd_coin_mint_cap</a>(
	arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>,
	mint_cap: MintCapability&lt;XUSDCoin&gt;,
	burn_cap: BurnCapability&lt;XUSDCoin&gt;
) {
    <a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);
    <b>move_to</b>(arx, <a href="moneta.md#0x1_moneta_XUSDCoinCapability">XUSDCoinCapability</a> { mint_cap, burn_cap })
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
