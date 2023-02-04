
<a name="0x1_vdf"></a>

# Module `0x1::vdf`



-  [Function `verify`](#0x1_vdf_verify)
-  [Function `address_from_challenge`](#0x1_vdf_address_from_challenge)


<pre><code></code></pre>



<a name="0x1_vdf_verify"></a>

## Function `verify`

Verifies a VDF proof.


<pre><code><b>public</b> <b>fun</b> <a href="vdf.md#0x1_vdf_verify">verify</a>(challenge: &<a href="vector.md#0x1_vector">vector</a>&lt;u8&gt;, solution: &<a href="vector.md#0x1_vector">vector</a>&lt;u8&gt;, difficulty: u64, security: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="vdf.md#0x1_vdf_verify">verify</a>(
	challenge: &<a href="vector.md#0x1_vector">vector</a>&lt;u8&gt;,
	solution: &<a href="vector.md#0x1_vector">vector</a>&lt;u8&gt;,
	difficulty: u64,
	security: u64,
): bool;
</code></pre>



</details>

<a name="0x1_vdf_address_from_challenge"></a>

## Function `address_from_challenge`

This is used for the 0th proof in a delay tower to ensure the tower belongs to a specific
authentication key and address.


<pre><code><b>public</b> <b>fun</b> <a href="vdf.md#0x1_vdf_address_from_challenge">address_from_challenge</a>(challenge: &<a href="vector.md#0x1_vector">vector</a>&lt;u8&gt;): (<b>address</b>, <a href="vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="vdf.md#0x1_vdf_address_from_challenge">address_from_challenge</a>(challenge: &<a href="vector.md#0x1_vector">vector</a>&lt;u8&gt;): (<b>address</b>, <a href="vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
