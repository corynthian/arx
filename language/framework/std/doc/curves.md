
<a name="0x1_curves"></a>

# Module `0x1::curves`



-  [Struct `Uncorrelated`](#0x1_curves_Uncorrelated)
-  [Struct `Stable`](#0x1_curves_Stable)
-  [Constants](#@Constants_0)
-  [Function `is_uncorrelated`](#0x1_curves_is_uncorrelated)
-  [Function `is_stable`](#0x1_curves_is_stable)
-  [Function `is_valid_curve`](#0x1_curves_is_valid_curve)
-  [Function `assert_valid_curve`](#0x1_curves_assert_valid_curve)


<pre><code><b>use</b> <a href="type_info.md#0x1_type_info">0x1::type_info</a>;
</code></pre>



<a name="0x1_curves_Uncorrelated"></a>

## Struct `Uncorrelated`

For uncorrelated pairs (BTC / ETH).


<pre><code><b>struct</b> <a href="curves.md#0x1_curves_Uncorrelated">Uncorrelated</a>
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

<a name="0x1_curves_Stable"></a>

## Struct `Stable`

For stable pairs (USDC / USDT).


<pre><code><b>struct</b> <a href="curves.md#0x1_curves_Stable">Stable</a>
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

<a name="@Constants_0"></a>

## Constants


<a name="0x1_curves_EINVALID_CURVE"></a>



<pre><code><b>const</b> <a href="curves.md#0x1_curves_EINVALID_CURVE">EINVALID_CURVE</a>: u64 = 1;
</code></pre>



<a name="0x1_curves_is_uncorrelated"></a>

## Function `is_uncorrelated`

Check provided <code>Curve</code> type is Uncorrelated.


<pre><code><b>public</b> <b>fun</b> <a href="curves.md#0x1_curves_is_uncorrelated">is_uncorrelated</a>&lt;Curve&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="curves.md#0x1_curves_is_uncorrelated">is_uncorrelated</a>&lt;Curve&gt;(): bool {
	<a href="type_info.md#0x1_type_info_type_of">type_info::type_of</a>&lt;Curve&gt;() == <a href="type_info.md#0x1_type_info_type_of">type_info::type_of</a>&lt;<a href="curves.md#0x1_curves_Uncorrelated">Uncorrelated</a>&gt;()
}
</code></pre>



</details>

<a name="0x1_curves_is_stable"></a>

## Function `is_stable`

Check provided <code>Curve</code> type is Stable.


<pre><code><b>public</b> <b>fun</b> <a href="curves.md#0x1_curves_is_stable">is_stable</a>&lt;Curve&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="curves.md#0x1_curves_is_stable">is_stable</a>&lt;Curve&gt;(): bool {
	<a href="type_info.md#0x1_type_info_type_of">type_info::type_of</a>&lt;Curve&gt;() == <a href="type_info.md#0x1_type_info_type_of">type_info::type_of</a>&lt;<a href="curves.md#0x1_curves_Stable">Stable</a>&gt;()
}
</code></pre>



</details>

<a name="0x1_curves_is_valid_curve"></a>

## Function `is_valid_curve`

Is <code>Curve</code> type valid or not (means correct type used).


<pre><code><b>public</b> <b>fun</b> <a href="curves.md#0x1_curves_is_valid_curve">is_valid_curve</a>&lt;Curve&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="curves.md#0x1_curves_is_valid_curve">is_valid_curve</a>&lt;Curve&gt;(): bool {
    <a href="curves.md#0x1_curves_is_uncorrelated">is_uncorrelated</a>&lt;Curve&gt;() || <a href="curves.md#0x1_curves_is_stable">is_stable</a>&lt;Curve&gt;()
}
</code></pre>



</details>

<a name="0x1_curves_assert_valid_curve"></a>

## Function `assert_valid_curve`

Checks if <code>Curve</code> is valid (means correct type used).


<pre><code><b>public</b> <b>fun</b> <a href="curves.md#0x1_curves_assert_valid_curve">assert_valid_curve</a>&lt;Curve&gt;()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="curves.md#0x1_curves_assert_valid_curve">assert_valid_curve</a>&lt;Curve&gt;() {
    <b>assert</b>!(<a href="curves.md#0x1_curves_is_valid_curve">is_valid_curve</a>&lt;Curve&gt;(), <a href="curves.md#0x1_curves_EINVALID_CURVE">EINVALID_CURVE</a>);
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
