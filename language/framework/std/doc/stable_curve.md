
<a name="0x1_stable_curve"></a>

# Module `0x1::stable_curve`

Implements stable curve math.


-  [Constants](#@Constants_0)
-  [Function `lp_value`](#0x1_stable_curve_lp_value)
-  [Function `coin_out`](#0x1_stable_curve_coin_out)
-  [Function `coin_in`](#0x1_stable_curve_coin_in)
-  [Function `get_y`](#0x1_stable_curve_get_y)
-  [Function `f`](#0x1_stable_curve_f)
-  [Function `d`](#0x1_stable_curve_d)


<pre><code><b>use</b> <a href="u256.md#0x1_u256">0x1::u256</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_stable_curve_ONE_E_8"></a>

We take 10^8 as we expect most of the coins to have 6-8 decimals.


<pre><code><b>const</b> <a href="stable_curve.md#0x1_stable_curve_ONE_E_8">ONE_E_8</a>: u128 = 100000000;
</code></pre>



<a name="0x1_stable_curve_lp_value"></a>

## Function `lp_value`

Get LP value for stable curve: x^3*y + x*y^3
* <code>x_coin</code> - reserves of coin X.
* <code>x_scale</code> - 10 pow X coin decimals amount.
* <code>y_coin</code> - reserves of coin Y.
* <code>y_scale</code> - 10 pow Y coin decimals amount.


<pre><code><b>public</b> <b>fun</b> <a href="stable_curve.md#0x1_stable_curve_lp_value">lp_value</a>(x_coin: u128, x_scale: u64, y_coin: u128, y_scale: u64): <a href="u256.md#0x1_u256_U256">u256::U256</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="stable_curve.md#0x1_stable_curve_lp_value">lp_value</a>(x_coin: u128, x_scale: u64, y_coin: u128, y_scale: u64): U256 {
    <b>let</b> x_u256 = <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(x_coin);
    <b>let</b> y_u256 = <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(y_coin);
    <b>let</b> u2561e8 = <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(<a href="stable_curve.md#0x1_stable_curve_ONE_E_8">ONE_E_8</a>);

    <b>let</b> x_scale_u256 = <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(x_scale);
    <b>let</b> y_scale_u256 = <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(y_scale);

    <b>let</b> _x = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(x_u256, u2561e8),
        x_scale_u256,
    );

    <b>let</b> _y = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(y_u256, u2561e8),
        y_scale_u256,
    );

    <b>let</b> _a = <a href="u256.md#0x1_u256_mul">u256::mul</a>(_x, _y);

    // ((_x * _x) / 1e18 + (_y * _y) / 1e18)
    <b>let</b> _b = <a href="u256.md#0x1_u256_add">u256::add</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(_x, _x),
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(_y, _y),
    );

    <a href="u256.md#0x1_u256_mul">u256::mul</a>(_a, _b)
}
</code></pre>



</details>

<a name="0x1_stable_curve_coin_out"></a>

## Function `coin_out`

Get coin amount out by passing amount in, returns amount out (we don't take fees into account here).
It probably would eat a lot of gas and better to do it offchain (on your frontend or whatever),
yet if no other way and need blockchain computation we left it here.
* <code>coin_in</code> - amount of coin to swap.
* <code>scale_in</code> - 10 pow by coin decimals you want to swap.
* <code>scale_out</code> - 10 pow by coin decimals you want to get.
* <code>reserve_in</code> - reserves of coin to swap coin_in.
* <code>reserve_out</code> - reserves of coin to get in exchange.


<pre><code><b>public</b> <b>fun</b> <a href="stable_curve.md#0x1_stable_curve_coin_out">coin_out</a>(coin_in: u128, scale_in: u64, scale_out: u64, reserve_in: u128, reserve_out: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="stable_curve.md#0x1_stable_curve_coin_out">coin_out</a>(coin_in: u128, scale_in: u64, scale_out: u64, reserve_in: u128, reserve_out: u128): u128 {
    <b>let</b> u2561e8 = <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(<a href="stable_curve.md#0x1_stable_curve_ONE_E_8">ONE_E_8</a>);

    <b>let</b> xy = <a href="stable_curve.md#0x1_stable_curve_lp_value">lp_value</a>(reserve_in, scale_in, reserve_out, scale_out);

    <b>let</b> reserve_in_u256 = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(
            <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(reserve_in),
            u2561e8,
        ),
        <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(scale_in),
    );
    <b>let</b> reserve_out_u256 = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(
            <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(reserve_out),
            u2561e8,
        ),
        <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(scale_out),
    );
    <b>let</b> amount_in = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(
            <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(coin_in),
            u2561e8
        ),
        <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(scale_in)
    );
    <b>let</b> total_reserve = <a href="u256.md#0x1_u256_add">u256::add</a>(amount_in, reserve_in_u256);
    <b>let</b> y = <a href="u256.md#0x1_u256_sub">u256::sub</a>(
        reserve_out_u256,
        <a href="stable_curve.md#0x1_stable_curve_get_y">get_y</a>(total_reserve, xy, reserve_out_u256),
    );

    <b>let</b> r = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(
            y,
            <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(scale_out),
        ),
        u2561e8
    );

    <a href="u256.md#0x1_u256_as_u128">u256::as_u128</a>(r)
}
</code></pre>



</details>

<a name="0x1_stable_curve_coin_in"></a>

## Function `coin_in`

Get coin amount in by passing amount out, returns amount in (we don't take fees into account here).
It probably would eat a lot of gas and better to do it offchain (on your frontend or whatever),
yet if no other way and need blockchain computation we left it here.
* <code>coin_out</code> - amount of coin you want to get.
* <code>scale_in</code> - 10 pow by coin decimals you want to swap.
* <code>scale_out</code> - 10 pow by coin decimals you want to get.
* <code>reserve_in</code> - reserves of coin to swap.
* <code>reserve_out</code> - reserves of coin to get in exchange.


<pre><code><b>public</b> <b>fun</b> <a href="stable_curve.md#0x1_stable_curve_coin_in">coin_in</a>(coin_out: u128, scale_out: u64, scale_in: u64, reserve_out: u128, reserve_in: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="stable_curve.md#0x1_stable_curve_coin_in">coin_in</a>(coin_out: u128, scale_out: u64, scale_in: u64, reserve_out: u128, reserve_in: u128): u128 {
    <b>let</b> u2561e8 = <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(<a href="stable_curve.md#0x1_stable_curve_ONE_E_8">ONE_E_8</a>);

    <b>let</b> xy = <a href="stable_curve.md#0x1_stable_curve_lp_value">lp_value</a>(reserve_in, scale_in, reserve_out, scale_out);

    <b>let</b> reserve_in_u256 = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(
            <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(reserve_in),
            u2561e8,
        ),
        <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(scale_in),
    );
    <b>let</b> reserve_out_u256 = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(
            <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(reserve_out),
            u2561e8,
        ),
        <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(scale_out),
    );
    <b>let</b> amount_out = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(
            <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(coin_out),
            u2561e8
        ),
        <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(scale_out)
    );

    <b>let</b> total_reserve = <a href="u256.md#0x1_u256_sub">u256::sub</a>(reserve_out_u256, amount_out);
    <b>let</b> x = <a href="u256.md#0x1_u256_sub">u256::sub</a>(
        <a href="stable_curve.md#0x1_stable_curve_get_y">get_y</a>(total_reserve, xy, reserve_in_u256),
        reserve_in_u256,
    );
    <b>let</b> r = <a href="u256.md#0x1_u256_div">u256::div</a>(
        <a href="u256.md#0x1_u256_mul">u256::mul</a>(
            x,
            <a href="u256.md#0x1_u256_from_u64">u256::from_u64</a>(scale_in),
        ),
        u2561e8
    );

    <a href="u256.md#0x1_u256_as_u128">u256::as_u128</a>(r)
}
</code></pre>



</details>

<a name="0x1_stable_curve_get_y"></a>

## Function `get_y`

Trying to find suitable <code>y</code> value.
* <code>x0</code> - total reserve x (include <code>coin_in</code>) with transformed decimals.
* <code>xy</code> - lp value (see <code>lp_value</code> func).
* <code>y</code> - reserves out with transformed decimals.


<pre><code><b>fun</b> <a href="stable_curve.md#0x1_stable_curve_get_y">get_y</a>(x0: <a href="u256.md#0x1_u256_U256">u256::U256</a>, xy: <a href="u256.md#0x1_u256_U256">u256::U256</a>, y: <a href="u256.md#0x1_u256_U256">u256::U256</a>): <a href="u256.md#0x1_u256_U256">u256::U256</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="stable_curve.md#0x1_stable_curve_get_y">get_y</a>(x0: U256, xy: U256, y: U256): U256 {
    <b>let</b> i = 0;

    <b>let</b> one_u256 = <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(1);

    <b>while</b> (i &lt; 255) {
        <b>let</b> k = <a href="stable_curve.md#0x1_stable_curve_f">f</a>(x0, y);

        <b>let</b> _dy = <a href="u256.md#0x1_u256_zero">u256::zero</a>();
        <b>let</b> cmp = <a href="u256.md#0x1_u256_compare">u256::compare</a>(&k, &xy);
        <b>if</b> (cmp == 1) {
            _dy = <a href="u256.md#0x1_u256_add">u256::add</a>(
                <a href="u256.md#0x1_u256_div">u256::div</a>(
                    <a href="u256.md#0x1_u256_sub">u256::sub</a>(xy, k),
                    <a href="stable_curve.md#0x1_stable_curve_d">d</a>(x0, y),
                ),
                one_u256    // Round up
            );
            y = <a href="u256.md#0x1_u256_add">u256::add</a>(y, _dy);
        } <b>else</b> {
            _dy = <a href="u256.md#0x1_u256_div">u256::div</a>(
                <a href="u256.md#0x1_u256_sub">u256::sub</a>(k, xy),
                <a href="stable_curve.md#0x1_stable_curve_d">d</a>(x0, y),
            );
            y = <a href="u256.md#0x1_u256_sub">u256::sub</a>(y, _dy);
        };
        cmp = <a href="u256.md#0x1_u256_compare">u256::compare</a>(&_dy, &one_u256);
        <b>if</b> (cmp == 0 || cmp == 1) {
            <b>return</b> y
        };

        i = i + 1;
    };

    y
}
</code></pre>



</details>

<a name="0x1_stable_curve_f"></a>

## Function `f`

Implements x0*y^3 + x0^3*y = x0*(y*y/1e18*y/1e18)/1e18+(x0*x0/1e18*x0/1e18)*y/1e18


<pre><code><b>fun</b> <a href="stable_curve.md#0x1_stable_curve_f">f</a>(x0_u256: <a href="u256.md#0x1_u256_U256">u256::U256</a>, y_u256: <a href="u256.md#0x1_u256_U256">u256::U256</a>): <a href="u256.md#0x1_u256_U256">u256::U256</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="stable_curve.md#0x1_stable_curve_f">f</a>(x0_u256: U256, y_u256: U256): U256 {
    // x0*(y*y/1e18*y/1e18)/1e18
    <b>let</b> yy = <a href="u256.md#0x1_u256_mul">u256::mul</a>(y_u256, y_u256);
    <b>let</b> yyy = <a href="u256.md#0x1_u256_mul">u256::mul</a>(yy, y_u256);

    <b>let</b> a = <a href="u256.md#0x1_u256_mul">u256::mul</a>(x0_u256, yyy);

    //(x0*x0/1e18*x0/1e18)*y/1e18
    <b>let</b> xx = <a href="u256.md#0x1_u256_mul">u256::mul</a>(x0_u256, x0_u256);
    <b>let</b> xxx = <a href="u256.md#0x1_u256_mul">u256::mul</a>(xx, x0_u256);
    <b>let</b> b = <a href="u256.md#0x1_u256_mul">u256::mul</a>(xxx, y_u256);

    // a + b
    <a href="u256.md#0x1_u256_add">u256::add</a>(a, b)
}
</code></pre>



</details>

<a name="0x1_stable_curve_d"></a>

## Function `d`

Implements 3 * x0 * y^2 + x0^3 = 3 * x0 * (y * y / 1e8) / 1e8 + (x0 * x0 / 1e8 * x0) / 1e8


<pre><code><b>fun</b> <a href="stable_curve.md#0x1_stable_curve_d">d</a>(x0_u256: <a href="u256.md#0x1_u256_U256">u256::U256</a>, y_u256: <a href="u256.md#0x1_u256_U256">u256::U256</a>): <a href="u256.md#0x1_u256_U256">u256::U256</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="stable_curve.md#0x1_stable_curve_d">d</a>(x0_u256: U256, y_u256: U256): U256 {
    <b>let</b> three_u256 = <a href="u256.md#0x1_u256_from_u128">u256::from_u128</a>(3);

    // 3 * x0 * (y * y / 1e8) / 1e8
    <b>let</b> x3 = <a href="u256.md#0x1_u256_mul">u256::mul</a>(three_u256, x0_u256);
    <b>let</b> yy = <a href="u256.md#0x1_u256_mul">u256::mul</a>(y_u256, y_u256);
    <b>let</b> xyy3 = <a href="u256.md#0x1_u256_mul">u256::mul</a>(x3, yy);
    <b>let</b> xx = <a href="u256.md#0x1_u256_mul">u256::mul</a>(x0_u256, x0_u256);

    // x0 * x0 / 1e8 * x0 / 1e8
    <b>let</b> xxx = <a href="u256.md#0x1_u256_mul">u256::mul</a>(xx, x0_u256);

    <a href="u256.md#0x1_u256_add">u256::add</a>(xyy3, xxx)
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
