
<a name="0x1_archon"></a>

# Module `0x1::archon`



-  [Resource `Archon`](#0x1_archon_Archon)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_archon_initialize)
-  [Function `get_owner_address`](#0x1_archon_get_owner_address)


<pre><code><b>use</b> <a href="arx_coin.md#0x1_arx_coin">0x1::arx_coin</a>;
<b>use</b> <a href="../../std/doc/bls12381.md#0x1_bls12381">0x1::bls12381</a>;
<b>use</b> <a href="../../std/doc/error.md#0x1_error">0x1::error</a>;
<b>use</b> <a href="../../std/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../std/doc/signer.md#0x1_signer">0x1::signer</a>;
<b>use</b> <a href="solaris.md#0x1_solaris">0x1::solaris</a>;
</code></pre>



<a name="0x1_archon_Archon"></a>

## Resource `Archon`



<pre><code><b>struct</b> <a href="archon.md#0x1_archon_Archon">Archon</a> <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>owner_address: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>consensus_pubkey: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>network_addresses: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>fullnode_addresses: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>validator_index: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>lux_power: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_archon_EINVALID_PUBLIC_KEY"></a>



<pre><code><b>const</b> <a href="archon.md#0x1_archon_EINVALID_PUBLIC_KEY">EINVALID_PUBLIC_KEY</a>: u64 = 1;
</code></pre>



<a name="0x1_archon_initialize"></a>

## Function `initialize`

Initializes a network archon with an initial allocation (if non-zero).


<pre><code><b>public</b> entry <b>fun</b> <a href="archon.md#0x1_archon_initialize">initialize</a>(<a href="account.md#0x1_account">account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, consensus_pubkey: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, proof_of_possession: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, network_addresses: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, fullnode_addresses: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, initial_allocation: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="archon.md#0x1_archon_initialize">initialize</a>(
	<a href="account.md#0x1_account">account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>,
	consensus_pubkey: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
	proof_of_possession: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
	network_addresses: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
	fullnode_addresses: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
	initial_allocation: u64,
) {
	// Checks the <b>public</b> key <b>has</b> a valid proof-of-possession <b>to</b> prevent rogue-key attacks.
    <b>let</b> pubkey_from_pop = &<b>mut</b> <a href="../../std/doc/bls12381.md#0x1_bls12381_public_key_from_bytes_with_pop">bls12381::public_key_from_bytes_with_pop</a>(
        consensus_pubkey,
        &proof_of_possession_from_bytes(proof_of_possession)
    );
    <b>assert</b>!(<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(pubkey_from_pop), <a href="../../std/doc/error.md#0x1_error_invalid_argument">error::invalid_argument</a>(<a href="archon.md#0x1_archon_EINVALID_PUBLIC_KEY">EINVALID_PUBLIC_KEY</a>));

	// Initialize the ArxCoin allocation.
	<b>if</b> (initial_allocation &gt; 0) {
	    <a href="solaris.md#0x1_solaris_initialize_allocation">solaris::initialize_allocation</a>&lt;ArxCoin&gt;(<a href="account.md#0x1_account">account</a>, initial_allocation);
	};

    <b>move_to</b>(<a href="account.md#0x1_account">account</a>, <a href="archon.md#0x1_archon_Archon">Archon</a> {
	    owner_address: <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(<a href="account.md#0x1_account">account</a>),
        consensus_pubkey,
        network_addresses,
        fullnode_addresses,
        validator_index: 0,
	    lux_power: 0,
    });
}
</code></pre>



</details>

<a name="0x1_archon_get_owner_address"></a>

## Function `get_owner_address`

Get the archons account address.


<pre><code><b>public</b> <b>fun</b> <a href="archon.md#0x1_archon_get_owner_address">get_owner_address</a>(<a href="archon.md#0x1_archon">archon</a>: &<a href="archon.md#0x1_archon_Archon">archon::Archon</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="archon.md#0x1_archon_get_owner_address">get_owner_address</a>(<a href="archon.md#0x1_archon">archon</a>: &<a href="archon.md#0x1_archon_Archon">Archon</a>): <b>address</b> {
	<a href="archon.md#0x1_archon">archon</a>.owner_address
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
