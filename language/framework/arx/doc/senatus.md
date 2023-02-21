
<a name="0x1_senatus"></a>

# Module `0x1::senatus`



-  [Resource `Senatus`](#0x1_senatus_Senatus)
-  [Struct `IndividualArchonPerformance`](#0x1_senatus_IndividualArchonPerformance)
-  [Resource `ArchonPerformance`](#0x1_senatus_ArchonPerformance)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_senatus_initialize)
-  [Function `add_coins`](#0x1_senatus_add_coins)
-  [Function `increase_joining_power`](#0x1_senatus_increase_joining_power)
-  [Function `is_active_archon`](#0x1_senatus_is_active_archon)
-  [Function `get_archon_state`](#0x1_senatus_get_archon_state)
-  [Function `find_archon`](#0x1_senatus_find_archon)
-  [Function `assert_solaris_exists`](#0x1_senatus_assert_solaris_exists)


<pre><code><b>use</b> <a href="archon.md#0x1_archon">0x1::archon</a>;
<b>use</b> <a href="../../std/doc/error.md#0x1_error">0x1::error</a>;
<b>use</b> <a href="../../std/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../std/doc/signer.md#0x1_signer">0x1::signer</a>;
<b>use</b> <a href="solaris.md#0x1_solaris">0x1::solaris</a>;
<b>use</b> <a href="system_addresses.md#0x1_system_addresses">0x1::system_addresses</a>;
</code></pre>



<a name="0x1_senatus_Senatus"></a>

## Resource `Senatus`



<pre><code><b>struct</b> <a href="senatus.md#0x1_senatus_Senatus">Senatus</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>consensus_scheme: u8</code>
</dt>
<dd>

</dd>
<dt>
<code>active: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<a href="archon.md#0x1_archon_Archon">archon::Archon</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>pending_inactive: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<a href="archon.md#0x1_archon_Archon">archon::Archon</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>pending_active: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<a href="archon.md#0x1_archon_Archon">archon::Archon</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>total_lux_power: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>total_joining_power: u128</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_senatus_IndividualArchonPerformance"></a>

## Struct `IndividualArchonPerformance`



<pre><code><b>struct</b> <a href="senatus.md#0x1_senatus_IndividualArchonPerformance">IndividualArchonPerformance</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>successful_proposals: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>failed_proposals: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_senatus_ArchonPerformance"></a>

## Resource `ArchonPerformance`



<pre><code><b>struct</b> <a href="senatus.md#0x1_senatus_ArchonPerformance">ArchonPerformance</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>archons: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<a href="senatus.md#0x1_senatus_IndividualArchonPerformance">senatus::IndividualArchonPerformance</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_senatus_ESOLARIS_DOES_NOT_EXIST"></a>

Attempted to use a non existent solaris position.


<pre><code><b>const</b> <a href="senatus.md#0x1_senatus_ESOLARIS_DOES_NOT_EXIST">ESOLARIS_DOES_NOT_EXIST</a>: u64 = 1;
</code></pre>



<a name="0x1_senatus_ARCHON_STATUS_ACTIVE"></a>



<pre><code><b>const</b> <a href="senatus.md#0x1_senatus_ARCHON_STATUS_ACTIVE">ARCHON_STATUS_ACTIVE</a>: u64 = 2;
</code></pre>



<a name="0x1_senatus_ARCHON_STATUS_INACTIVE"></a>



<pre><code><b>const</b> <a href="senatus.md#0x1_senatus_ARCHON_STATUS_INACTIVE">ARCHON_STATUS_INACTIVE</a>: u64 = 4;
</code></pre>



<a name="0x1_senatus_ARCHON_STATUS_PENDING_ACTIVE"></a>

Archon status enum. We can switch to proper enum later once Move supports it.


<pre><code><b>const</b> <a href="senatus.md#0x1_senatus_ARCHON_STATUS_PENDING_ACTIVE">ARCHON_STATUS_PENDING_ACTIVE</a>: u64 = 1;
</code></pre>



<a name="0x1_senatus_ARCHON_STATUS_PENDING_INACTIVE"></a>



<pre><code><b>const</b> <a href="senatus.md#0x1_senatus_ARCHON_STATUS_PENDING_INACTIVE">ARCHON_STATUS_PENDING_INACTIVE</a>: u64 = 3;
</code></pre>



<a name="0x1_senatus_initialize"></a>

## Function `initialize`

Initialises the senatus, tracking archon performance. Called from genesis.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="senatus.md#0x1_senatus_initialize">initialize</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="senatus.md#0x1_senatus_initialize">initialize</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>) {
	<a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);

	<b>move_to</b>(arx, <a href="senatus.md#0x1_senatus_Senatus">Senatus</a> {
	    consensus_scheme: 0,
	    active: <a href="../../std/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
	    pending_active: <a href="../../std/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
	    pending_inactive: <a href="../../std/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
	    total_lux_power: 0,
	    total_joining_power: 0,
	});
	<b>move_to</b>(arx, <a href="senatus.md#0x1_senatus_ArchonPerformance">ArchonPerformance</a> {
	    archons: <a href="../../std/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
	});
}
</code></pre>



</details>

<a name="0x1_senatus_add_coins"></a>

## Function `add_coins`

Adds coins to an archons solaris.


<pre><code><b>public</b> entry <b>fun</b> <a href="senatus.md#0x1_senatus_add_coins">add_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="senatus.md#0x1_senatus_add_coins">add_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
	<b>acquires</b> <a href="senatus.md#0x1_senatus_Senatus">Senatus</a>
{
	<b>let</b> archon_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);
	<a href="solaris.md#0x1_solaris_assert_exists">solaris::assert_exists</a>&lt;CoinType&gt;(archon_address);

	// Add coins and add pending_active seignorage <b>if</b> the <a href="archon.md#0x1_archon">archon</a> is currently active in order <b>to</b>
	// make the seignorage count in the next epoch. If the <a href="archon.md#0x1_archon">archon</a> is not yet active then the
	// seignorage can be immediately added <b>to</b> active, since they will activate in the next epoch.
	<b>if</b> (<a href="senatus.md#0x1_senatus_is_active_archon">is_active_archon</a>(archon_address)) {
	    <a href="solaris.md#0x1_solaris_add_pending_coins">solaris::add_pending_coins</a>&lt;CoinType&gt;(owner, amount);
	} <b>else</b> {
	    <a href="solaris.md#0x1_solaris_add_active_coins">solaris::add_active_coins</a>&lt;CoinType&gt;(owner, amount);
	};

    // Only track and validate lux power increases for active and pending_active archons.
    // pending_inactive archons will be removed from the <a href="senatus.md#0x1_senatus">senatus</a> in the next epoch.
    // Inactive archons total stake will be tracked when they join the <a href="senatus.md#0x1_senatus">senatus</a>.
    <b>let</b> <a href="senatus.md#0x1_senatus">senatus</a> = <b>borrow_global_mut</b>&lt;<a href="senatus.md#0x1_senatus_Senatus">Senatus</a>&gt;(@arx);
    // Search directly rather using get_archon_state <b>to</b> save on unnecessary loops.
    <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="senatus.md#0x1_senatus_find_archon">find_archon</a>(&<a href="senatus.md#0x1_senatus">senatus</a>.active, archon_address)) ||
        <a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="senatus.md#0x1_senatus_find_archon">find_archon</a>(&<a href="senatus.md#0x1_senatus">senatus</a>.pending_active, archon_address))) {
        <a href="senatus.md#0x1_senatus_increase_joining_power">increase_joining_power</a>(amount);
    };
	// TODO: Check for minimum / maximum power
}
</code></pre>



</details>

<a name="0x1_senatus_increase_joining_power"></a>

## Function `increase_joining_power`



<pre><code><b>fun</b> <a href="senatus.md#0x1_senatus_increase_joining_power">increase_joining_power</a>(amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="senatus.md#0x1_senatus_increase_joining_power">increase_joining_power</a>(amount: u64) <b>acquires</b> <a href="senatus.md#0x1_senatus_Senatus">Senatus</a> {
	<b>let</b> <a href="senatus.md#0x1_senatus">senatus</a> = <b>borrow_global_mut</b>&lt;<a href="senatus.md#0x1_senatus_Senatus">Senatus</a>&gt;(@arx);
	<a href="senatus.md#0x1_senatus">senatus</a>.total_joining_power = <a href="senatus.md#0x1_senatus">senatus</a>.total_joining_power + (amount <b>as</b> u128);
	// TODO: Check for minimum / maximum power
}
</code></pre>



</details>

<a name="0x1_senatus_is_active_archon"></a>

## Function `is_active_archon`

Returns true is the specified archon is still participating in consensus as a validator.
This includes archons which have requested to leave but are pending inactive.


<pre><code><b>public</b> <b>fun</b> <a href="senatus.md#0x1_senatus_is_active_archon">is_active_archon</a>(archon_address: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="senatus.md#0x1_senatus_is_active_archon">is_active_archon</a>(archon_address: <b>address</b>): bool <b>acquires</b> <a href="senatus.md#0x1_senatus_Senatus">Senatus</a> {
	<a href="senatus.md#0x1_senatus_assert_solaris_exists">assert_solaris_exists</a>(archon_address);
	<b>let</b> archon_state = <a href="senatus.md#0x1_senatus_get_archon_state">get_archon_state</a>(archon_address);
	archon_state == <a href="senatus.md#0x1_senatus_ARCHON_STATUS_ACTIVE">ARCHON_STATUS_ACTIVE</a> || archon_state == <a href="senatus.md#0x1_senatus_ARCHON_STATUS_PENDING_INACTIVE">ARCHON_STATUS_PENDING_INACTIVE</a>
}
</code></pre>



</details>

<a name="0x1_senatus_get_archon_state"></a>

## Function `get_archon_state`

Returns the archons current state in terms of consensus.


<pre><code><b>fun</b> <a href="senatus.md#0x1_senatus_get_archon_state">get_archon_state</a>(archon_address: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="senatus.md#0x1_senatus_get_archon_state">get_archon_state</a>(archon_address: <b>address</b>): u64 <b>acquires</b> <a href="senatus.md#0x1_senatus_Senatus">Senatus</a> {
    <b>let</b> <a href="senatus.md#0x1_senatus">senatus</a> = <b>borrow_global</b>&lt;<a href="senatus.md#0x1_senatus_Senatus">Senatus</a>&gt;(@arx);
    <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="senatus.md#0x1_senatus_find_archon">find_archon</a>(&<a href="senatus.md#0x1_senatus">senatus</a>.pending_active, archon_address))) {
        <a href="senatus.md#0x1_senatus_ARCHON_STATUS_PENDING_ACTIVE">ARCHON_STATUS_PENDING_ACTIVE</a>
    } <b>else</b> <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="senatus.md#0x1_senatus_find_archon">find_archon</a>(&<a href="senatus.md#0x1_senatus">senatus</a>.active, archon_address))) {
        <a href="senatus.md#0x1_senatus_ARCHON_STATUS_ACTIVE">ARCHON_STATUS_ACTIVE</a>
    } <b>else</b> <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="senatus.md#0x1_senatus_find_archon">find_archon</a>(&<a href="senatus.md#0x1_senatus">senatus</a>.pending_inactive, archon_address))) {
        <a href="senatus.md#0x1_senatus_ARCHON_STATUS_PENDING_INACTIVE">ARCHON_STATUS_PENDING_INACTIVE</a>
    } <b>else</b> {
        <a href="senatus.md#0x1_senatus_ARCHON_STATUS_INACTIVE">ARCHON_STATUS_INACTIVE</a>
    }
}
</code></pre>



</details>

<a name="0x1_senatus_find_archon"></a>

## Function `find_archon`

Finds an archon registered in the senatus by address.


<pre><code><b>fun</b> <a href="senatus.md#0x1_senatus_find_archon">find_archon</a>(v: &<a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<a href="archon.md#0x1_archon_Archon">archon::Archon</a>&gt;, addr: <b>address</b>): <a href="../../std/doc/option.md#0x1_option_Option">option::Option</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="senatus.md#0x1_senatus_find_archon">find_archon</a>(v: &<a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;Archon&gt;, addr: <b>address</b>): Option&lt;u64&gt; {
    <b>let</b> i = 0;
    <b>let</b> len = <a href="../../std/doc/vector.md#0x1_vector_length">vector::length</a>(v);
    <b>while</b> ({
        <b>spec</b> {
            <b>invariant</b> !(<b>exists</b> j in 0..i: <a href="archon.md#0x1_archon_get_owner_address">archon::get_owner_address</a>(v[j]) == addr);
        };
        i &lt; len
    }) {
        <b>if</b> (<a href="archon.md#0x1_archon_get_owner_address">archon::get_owner_address</a>(<a href="../../std/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(v, i)) == addr) {
            <b>return</b> <a href="../../std/doc/option.md#0x1_option_some">option::some</a>(i)
        };
        i = i + 1;
    };
    <a href="../../std/doc/option.md#0x1_option_none">option::none</a>()
}
</code></pre>



</details>

<a name="0x1_senatus_assert_solaris_exists"></a>

## Function `assert_solaris_exists`

Ensures a solaris exists of either ArxCoin or LP<ArxCoin, XUSDCoin, Stable> at the supplied
address.


<pre><code><b>fun</b> <a href="senatus.md#0x1_senatus_assert_solaris_exists">assert_solaris_exists</a>(archon_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="senatus.md#0x1_senatus_assert_solaris_exists">assert_solaris_exists</a>(archon_address: <b>address</b>) {
	<b>assert</b>!(
	    <a href="solaris.md#0x1_solaris_exists_arxcoin">solaris::exists_arxcoin</a>(archon_address) || <a href="solaris.md#0x1_solaris_exists_lp">solaris::exists_lp</a>(archon_address),
	    <a href="../../std/doc/error.md#0x1_error_invalid_argument">error::invalid_argument</a>(<a href="senatus.md#0x1_senatus_ESOLARIS_DOES_NOT_EXIST">ESOLARIS_DOES_NOT_EXIST</a>)
	);
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
