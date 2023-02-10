
<a name="0x1_forma"></a>

# Module `0x1::forma`

Incitamentum definitionis


-  [Resource `Forma`](#0x1_forma_Forma)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_forma_initialize)
-  [Function `register`](#0x1_forma_register)
-  [Function `assert_exists`](#0x1_forma_assert_exists)
-  [Function `get_lux_incentive`](#0x1_forma_get_lux_incentive)
-  [Function `get_nox_incentive`](#0x1_forma_get_nox_incentive)


<pre><code><b>use</b> <a href="arx_coin.md#0x1_arx_coin">0x1::arx_coin</a>;
<b>use</b> <a href="chain_status.md#0x1_chain_status">0x1::chain_status</a>;
<b>use</b> <a href="../../std/doc/curves.md#0x1_curves">0x1::curves</a>;
<b>use</b> <a href="../../std/doc/error.md#0x1_error">0x1::error</a>;
<b>use</b> <a href="lp_coin.md#0x1_lp_coin">0x1::lp_coin</a>;
<b>use</b> <a href="system_addresses.md#0x1_system_addresses">0x1::system_addresses</a>;
<b>use</b> <a href="xusd_coin.md#0x1_xusd_coin">0x1::xusd_coin</a>;
</code></pre>



<a name="0x1_forma_Forma"></a>

## Resource `Forma`



<pre><code><b>struct</b> <a href="forma.md#0x1_forma_Forma">Forma</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>lux_incentive: u64</code>
</dt>
<dd>
 The lux incentive of this forma.
</dd>
<dt>
<code>nox_incentive: u64</code>
</dt>
<dd>
 The nox incentive of this forma.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_forma_EFORMA_NOT_FOUND"></a>

A forma was not found for the specified coin type.


<pre><code><b>const</b> <a href="forma.md#0x1_forma_EFORMA_NOT_FOUND">EFORMA_NOT_FOUND</a>: u64 = 1;
</code></pre>



<a name="0x1_forma_initialize"></a>

## Function `initialize`

Initialises the bona configuration.
Called at genesis and required in order to initialize the validator set.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="forma.md#0x1_forma_initialize">initialize</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="forma.md#0x1_forma_initialize">initialize</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>) {
	<a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>);
	<a href="chain_status.md#0x1_chain_status_assert_genesis">chain_status::assert_genesis</a>();

	<a href="forma.md#0x1_forma_register">register</a>&lt;ArxCoin&gt;(<a href="arx_account.md#0x1_arx_account">arx_account</a>, 1, 1);
	<a href="forma.md#0x1_forma_register">register</a>&lt;LP&lt;ArxCoin, XUSDCoin, Stable&gt;&gt;(<a href="arx_account.md#0x1_arx_account">arx_account</a>, 1, 1);
}
</code></pre>



</details>

<a name="0x1_forma_register"></a>

## Function `register`

Registers a new forma which allows for the existence of a solaris of the same coin type.


<pre><code><b>public</b> <b>fun</b> <a href="forma.md#0x1_forma_register">register</a>&lt;CoinType&gt;(<a href="arx_account.md#0x1_arx_account">arx_account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, lux_incentive: u64, nox_incentive: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="forma.md#0x1_forma_register">register</a>&lt;CoinType&gt;(
	<a href="arx_account.md#0x1_arx_account">arx_account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>,
	lux_incentive: u64,
	nox_incentive: u64,
) {
	<a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(<a href="arx_account.md#0x1_arx_account">arx_account</a>);
	<b>move_to</b>(<a href="arx_account.md#0x1_arx_account">arx_account</a>, <a href="forma.md#0x1_forma_Forma">Forma</a>&lt;CoinType&gt; {
	    lux_incentive,
	    nox_incentive,
	});
}
</code></pre>



</details>

<a name="0x1_forma_assert_exists"></a>

## Function `assert_exists`

Ensures a coin type is permitted to be added to servo.


<pre><code><b>public</b> <b>fun</b> <a href="forma.md#0x1_forma_assert_exists">assert_exists</a>&lt;CoinType&gt;()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="forma.md#0x1_forma_assert_exists">assert_exists</a>&lt;CoinType&gt;() {
	<b>assert</b>!(<b>exists</b>&lt;<a href="forma.md#0x1_forma_Forma">Forma</a>&lt;CoinType&gt;&gt;(@arx), <a href="../../std/doc/error.md#0x1_error_not_found">error::not_found</a>(<a href="forma.md#0x1_forma_EFORMA_NOT_FOUND">EFORMA_NOT_FOUND</a>));
}
</code></pre>



</details>

<a name="0x1_forma_get_lux_incentive"></a>

## Function `get_lux_incentive`

Returns the lux incentive of the forma.


<pre><code><b>public</b> <b>fun</b> <a href="forma.md#0x1_forma_get_lux_incentive">get_lux_incentive</a>&lt;CoinType&gt;(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="forma.md#0x1_forma_get_lux_incentive">get_lux_incentive</a>&lt;CoinType&gt;(): u64 <b>acquires</b> <a href="forma.md#0x1_forma_Forma">Forma</a> {
	<b>borrow_global</b>&lt;<a href="forma.md#0x1_forma_Forma">Forma</a>&lt;CoinType&gt;&gt;(@arx).lux_incentive
}
</code></pre>



</details>

<a name="0x1_forma_get_nox_incentive"></a>

## Function `get_nox_incentive`

Returns the nox incentive of the forma.


<pre><code><b>public</b> <b>fun</b> <a href="forma.md#0x1_forma_get_nox_incentive">get_nox_incentive</a>&lt;CoinType&gt;(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="forma.md#0x1_forma_get_nox_incentive">get_nox_incentive</a>&lt;CoinType&gt;(): u64 <b>acquires</b> <a href="forma.md#0x1_forma_Forma">Forma</a> {
	<b>borrow_global</b>&lt;<a href="forma.md#0x1_forma_Forma">Forma</a>&lt;CoinType&gt;&gt;(@arx).nox_incentive
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
