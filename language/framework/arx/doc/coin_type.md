
<a name="0x1_coin_type"></a>

# Module `0x1::coin_type`

Contains functions which deal with coin type checking and comparison.


-  [Constants](#@Constants_0)
-  [Function `assert_coin_initialized`](#0x1_coin_type_assert_coin_initialized)
-  [Function `compare`](#0x1_coin_type_compare)
-  [Function `preserves_ordering`](#0x1_coin_type_preserves_ordering)
-  [Function `supply`](#0x1_coin_type_supply)
-  [Function `generate_lp_name_and_symbol`](#0x1_coin_type_generate_lp_name_and_symbol)
-  [Function `coin_symbol_prefix`](#0x1_coin_type_coin_symbol_prefix)


<pre><code><b>use</b> <a href="coin.md#0x1_coin">0x1::coin</a>;
<b>use</b> <a href="../../std/doc/comparator.md#0x1_comparator">0x1::comparator</a>;
<b>use</b> <a href="../../std/doc/curves.md#0x1_curves">0x1::curves</a>;
<b>use</b> <a href="../../std/doc/math64.md#0x1_math64">0x1::math64</a>;
<b>use</b> <a href="../../std/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../std/doc/string.md#0x1_string">0x1::string</a>;
<b>use</b> <a href="../../std/doc/type_info.md#0x1_type_info">0x1::type_info</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_coin_type_ENOT_A_COIN"></a>

When provided CoinType is not a coin.


<pre><code><b>const</b> <a href="coin_type.md#0x1_coin_type_ENOT_A_COIN">ENOT_A_COIN</a>: u64 = 3001;
</code></pre>



<a name="0x1_coin_type_ESAME_COIN"></a>

When both coins have the same name and cannot be ordered.


<pre><code><b>const</b> <a href="coin_type.md#0x1_coin_type_ESAME_COIN">ESAME_COIN</a>: u64 = 3000;
</code></pre>



<a name="0x1_coin_type_SYMBOL_PREFIX_LENGTH"></a>

Length of symbol prefix to be used in LP coin symbol.


<pre><code><b>const</b> <a href="coin_type.md#0x1_coin_type_SYMBOL_PREFIX_LENGTH">SYMBOL_PREFIX_LENGTH</a>: u64 = 4;
</code></pre>



<a name="0x1_coin_type_assert_coin_initialized"></a>

## Function `assert_coin_initialized`

Check if provided generic <code>CoinType</code> is a coin.


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_assert_coin_initialized">assert_coin_initialized</a>&lt;CoinType&gt;()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_assert_coin_initialized">assert_coin_initialized</a>&lt;CoinType&gt;() {
    <b>assert</b>!(<a href="coin.md#0x1_coin_is_coin_initialized">coin::is_coin_initialized</a>&lt;CoinType&gt;(), <a href="coin_type.md#0x1_coin_type_ENOT_A_COIN">ENOT_A_COIN</a>);
}
</code></pre>



</details>

<a name="0x1_coin_type_compare"></a>

## Function `compare`

Compare two coins, <code>X</code> and <code>Y</code>, using names.
Caller should call this function to determine the order of X, Y.


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_compare">compare</a>&lt;X, Y&gt;(): <a href="../../std/doc/comparator.md#0x1_comparator_Result">comparator::Result</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_compare">compare</a>&lt;X, Y&gt;(): Result {
    <b>let</b> x_info = <a href="../../std/doc/type_info.md#0x1_type_info_type_of">type_info::type_of</a>&lt;X&gt;();
    <b>let</b> y_info = <a href="../../std/doc/type_info.md#0x1_type_info_type_of">type_info::type_of</a>&lt;Y&gt;();

    // 1. compare struct_name
    <b>let</b> x_struct_name = <a href="../../std/doc/type_info.md#0x1_type_info_struct_name">type_info::struct_name</a>(&x_info);
    <b>let</b> y_struct_name = <a href="../../std/doc/type_info.md#0x1_type_info_struct_name">type_info::struct_name</a>(&y_info);
    <b>let</b> struct_cmp = <a href="../../std/doc/comparator.md#0x1_comparator_compare">comparator::compare</a>(&x_struct_name, &y_struct_name);
    <b>if</b> (!<a href="../../std/doc/comparator.md#0x1_comparator_is_equal">comparator::is_equal</a>(&struct_cmp)) <b>return</b> struct_cmp;

    // 2. <b>if</b> <b>struct</b> names are equal, compare <b>module</b> name
    <b>let</b> x_module_name = <a href="../../std/doc/type_info.md#0x1_type_info_module_name">type_info::module_name</a>(&x_info);
    <b>let</b> y_module_name = <a href="../../std/doc/type_info.md#0x1_type_info_module_name">type_info::module_name</a>(&y_info);
    <b>let</b> module_cmp = <a href="../../std/doc/comparator.md#0x1_comparator_compare">comparator::compare</a>(&x_module_name, &y_module_name);
    <b>if</b> (!<a href="../../std/doc/comparator.md#0x1_comparator_is_equal">comparator::is_equal</a>(&module_cmp)) <b>return</b> module_cmp;

    // 3. <b>if</b> modules are equal, compare addresses
    <b>let</b> x_address = <a href="../../std/doc/type_info.md#0x1_type_info_account_address">type_info::account_address</a>(&x_info);
    <b>let</b> y_address = <a href="../../std/doc/type_info.md#0x1_type_info_account_address">type_info::account_address</a>(&y_info);
    <b>let</b> address_cmp = <a href="../../std/doc/comparator.md#0x1_comparator_compare">comparator::compare</a>(&x_address, &y_address);

    address_cmp
}
</code></pre>



</details>

<a name="0x1_coin_type_preserves_ordering"></a>

## Function `preserves_ordering`

Check that coins generics <code>X</code>, <code>Y</code> are sorted in correct ordering.
X != Y && X.symbol < Y.symbol


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_preserves_ordering">preserves_ordering</a>&lt;X, Y&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_preserves_ordering">preserves_ordering</a>&lt;X, Y&gt;(): bool {
    <b>let</b> order = <a href="coin_type.md#0x1_coin_type_compare">compare</a>&lt;X, Y&gt;();
    <b>assert</b>!(!<a href="../../std/doc/comparator.md#0x1_comparator_is_equal">comparator::is_equal</a>(&order), <a href="coin_type.md#0x1_coin_type_ESAME_COIN">ESAME_COIN</a>);
    <a href="../../std/doc/comparator.md#0x1_comparator_is_smaller_than">comparator::is_smaller_than</a>(&order)
}
</code></pre>



</details>

<a name="0x1_coin_type_supply"></a>

## Function `supply`

Get supply for <code>CoinType</code>.
Would throw error if supply for <code>CoinType</code> doesn't exist.


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_supply">supply</a>&lt;CoinType&gt;(): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_supply">supply</a>&lt;CoinType&gt;(): u128 {
    <a href="../../std/doc/option.md#0x1_option_extract">option::extract</a>(&<b>mut</b> <a href="coin.md#0x1_coin_supply">coin::supply</a>&lt;CoinType&gt;())
}
</code></pre>



</details>

<a name="0x1_coin_type_generate_lp_name_and_symbol"></a>

## Function `generate_lp_name_and_symbol`

Generate LP coin name and symbol for pair <code>X</code>/<code>Y</code> and curve <code>Curve</code>.
```
(curve_name, curve_symbol) = when(curve) {
is Uncorrelated -> ("::U", "(no symbol)")
is Stable -> ("::S", "*")
}
name = "LP::" + symbol<X>() + "-" + symbol<Y>() + curve_name;
symbol = symbol<X>()[0:4] + "-" + symbol<Y>()[0:4] + curve_symbol;
```
For example, for <code>LP&lt;BTC, USDT, Uncorrelated&gt;</code>,
the result will be <code>(b"LP::BTC-USDT::U", b"BTC-USDT")</code>


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_generate_lp_name_and_symbol">generate_lp_name_and_symbol</a>&lt;X, Y, Curve&gt;(): (<a href="../../std/doc/string.md#0x1_string_String">string::String</a>, <a href="../../std/doc/string.md#0x1_string_String">string::String</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="coin_type.md#0x1_coin_type_generate_lp_name_and_symbol">generate_lp_name_and_symbol</a>&lt;X, Y, Curve&gt;(): (String, String) {
    <b>let</b> lp_name = <a href="../../std/doc/string.md#0x1_string_utf8">string::utf8</a>(b"");
    <a href="../../std/doc/string.md#0x1_string_append_utf8">string::append_utf8</a>(&<b>mut</b> lp_name, b"LP::");
    <a href="../../std/doc/string.md#0x1_string_append">string::append</a>(&<b>mut</b> lp_name, <a href="coin.md#0x1_coin_symbol">coin::symbol</a>&lt;X&gt;());
    <a href="../../std/doc/string.md#0x1_string_append_utf8">string::append_utf8</a>(&<b>mut</b> lp_name, b"-");
    <a href="../../std/doc/string.md#0x1_string_append">string::append</a>(&<b>mut</b> lp_name, <a href="coin.md#0x1_coin_symbol">coin::symbol</a>&lt;Y&gt;());

    <b>let</b> lp_symbol = <a href="../../std/doc/string.md#0x1_string_utf8">string::utf8</a>(b"");
    <a href="../../std/doc/string.md#0x1_string_append">string::append</a>(&<b>mut</b> lp_symbol, <a href="coin_type.md#0x1_coin_type_coin_symbol_prefix">coin_symbol_prefix</a>&lt;X&gt;());
    <a href="../../std/doc/string.md#0x1_string_append_utf8">string::append_utf8</a>(&<b>mut</b> lp_symbol, b"-");
    <a href="../../std/doc/string.md#0x1_string_append">string::append</a>(&<b>mut</b> lp_symbol, <a href="coin_type.md#0x1_coin_type_coin_symbol_prefix">coin_symbol_prefix</a>&lt;Y&gt;());

    <b>let</b> (curve_name, curve_symbol) =
	    <b>if</b> (is_stable&lt;Curve&gt;()) {
		(b"::S", b"*")
	    } <b>else</b> {
		(b"::U", b"")
	    };
    <a href="../../std/doc/string.md#0x1_string_append_utf8">string::append_utf8</a>(&<b>mut</b> lp_name, curve_name);
    <a href="../../std/doc/string.md#0x1_string_append_utf8">string::append_utf8</a>(&<b>mut</b> lp_symbol, curve_symbol);

    (lp_name, lp_symbol)
}
</code></pre>



</details>

<a name="0x1_coin_type_coin_symbol_prefix"></a>

## Function `coin_symbol_prefix`



<pre><code><b>fun</b> <a href="coin_type.md#0x1_coin_type_coin_symbol_prefix">coin_symbol_prefix</a>&lt;CoinType&gt;(): <a href="../../std/doc/string.md#0x1_string_String">string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="coin_type.md#0x1_coin_type_coin_symbol_prefix">coin_symbol_prefix</a>&lt;CoinType&gt;(): String {
    <b>let</b> symbol = <a href="coin.md#0x1_coin_symbol">coin::symbol</a>&lt;CoinType&gt;();
    <b>let</b> prefix_length = <a href="../../std/doc/math64.md#0x1_math64_min">math64::min</a>(<a href="../../std/doc/string.md#0x1_string_length">string::length</a>(&symbol), <a href="coin_type.md#0x1_coin_type_SYMBOL_PREFIX_LENGTH">SYMBOL_PREFIX_LENGTH</a>);
    <a href="../../std/doc/string.md#0x1_string_sub_string">string::sub_string</a>(&symbol, 0, prefix_length)
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
