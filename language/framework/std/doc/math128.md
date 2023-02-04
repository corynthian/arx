
<a name="0x1_math128"></a>

# Module `0x1::math128`

Standard math utilities missing in the Move Language.


-  [Constants](#@Constants_0)
-  [Function `overflow_add`](#0x1_math128_overflow_add)
-  [Function `mul_div`](#0x1_math128_mul_div)
-  [Function `sqrt`](#0x1_math128_sqrt)
-  [Function `max`](#0x1_math128_max)
-  [Function `min`](#0x1_math128_min)
-  [Function `average`](#0x1_math128_average)
-  [Function `pow`](#0x1_math128_pow)
-  [Specification](#@Specification_1)
    -  [Function `max`](#@Specification_1_max)
    -  [Function `min`](#@Specification_1_min)
    -  [Function `average`](#@Specification_1_average)
    -  [Function `pow`](#@Specification_1_pow)


<pre><code></code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x1_math128_MAX_U128"></a>

Maximum of u128 number.


<pre><code><b>const</b> <a href="math128.md#0x1_math128_MAX_U128">MAX_U128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a name="0x1_math128_EDIVIDE_BY_ZERO"></a>



<pre><code><b>const</b> <a href="math128.md#0x1_math128_EDIVIDE_BY_ZERO">EDIVIDE_BY_ZERO</a>: u64 = 2000;
</code></pre>



<a name="0x1_math128_overflow_add"></a>

## Function `overflow_add`

Adds two u128 and makes overflow possible.


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_overflow_add">overflow_add</a>(a: u128, b: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_overflow_add">overflow_add</a>(a: u128, b: u128): u128 {
    <b>let</b> r = <a href="math128.md#0x1_math128_MAX_U128">MAX_U128</a> - b;
    <b>if</b> (r &lt; a) {
        <b>return</b> a - r - 1
    };
    r = <a href="math128.md#0x1_math128_MAX_U128">MAX_U128</a> - a;
    <b>if</b> (r &lt; b) {
        <b>return</b> b - r - 1
    };

    a + b
}
</code></pre>



</details>

<a name="0x1_math128_mul_div"></a>

## Function `mul_div`

Implements: <code>x</code> * <code>y</code> / <code>z</code>.


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_mul_div">mul_div</a>(x: u128, y: u128, z: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_mul_div">mul_div</a>(x: u128, y: u128, z: u128): u64 {
    <b>assert</b>!(z != 0, <a href="math128.md#0x1_math128_EDIVIDE_BY_ZERO">EDIVIDE_BY_ZERO</a>);
    <b>let</b> r = x * y / z;
    (r <b>as</b> u64)
}
</code></pre>



</details>

<a name="0x1_math128_sqrt"></a>

## Function `sqrt`

Get square root of <code>y</code>.
Babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_sqrt">sqrt</a>(y: u128): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_sqrt">sqrt</a>(y: u128): u64 {
    <b>if</b> (y &lt; 4) {
        <b>if</b> (y == 0) {
            0u64
        } <b>else</b> {
            1u64
        }
    } <b>else</b> {
        <b>let</b> z = y;
        <b>let</b> x = y / 2 + 1;
        <b>while</b> (x &lt; z) {
            z = x;
            x = (y / x + x) / 2;
        };
        (z <b>as</b> u64)
    }
}
</code></pre>



</details>

<a name="0x1_math128_max"></a>

## Function `max`

Return the largest of two numbers.


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_max">max</a>(a: u128, b: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_max">max</a>(a: u128, b: u128): u128 {
    <b>if</b> (a &gt;= b) a <b>else</b> b
}
</code></pre>



</details>

<a name="0x1_math128_min"></a>

## Function `min`

Return the smallest of two numbers.


<pre><code><b>public</b> <b>fun</b> <b>min</b>(a: u128, b: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <b>min</b>(a: u128, b: u128): u128 {
    <b>if</b> (a &lt; b) a <b>else</b> b
}
</code></pre>



</details>

<a name="0x1_math128_average"></a>

## Function `average`

Return the average of two.


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_average">average</a>(a: u128, b: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_average">average</a>(a: u128, b: u128): u128 {
    <b>if</b> (a &lt; b) {
        a + (b - a) / 2
    } <b>else</b> {
        b + (a - b) / 2
    }
}
</code></pre>



</details>

<a name="0x1_math128_pow"></a>

## Function `pow`

Return the value of n raised to power e


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_pow">pow</a>(n: u128, e: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_pow">pow</a>(n: u128, e: u128): u128 {
    <b>if</b> (e == 0) {
        1
    } <b>else</b> {
        <b>let</b> p = 1;
        <b>while</b> (e &gt; 1) {
            <b>if</b> (e % 2 == 1) {
                p = p * n;
            };
            e = e / 2;
            n = n * n;
        };
        p * n
    }
}
</code></pre>



</details>

<a name="@Specification_1"></a>

## Specification


<a name="@Specification_1_max"></a>

### Function `max`


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_max">max</a>(a: u128, b: u128): u128
</code></pre>




<pre><code><b>aborts_if</b> <b>false</b>;
<b>ensures</b> a &gt;= b ==&gt; result == a;
<b>ensures</b> a &lt; b ==&gt; result == b;
</code></pre>



<a name="@Specification_1_min"></a>

### Function `min`


<pre><code><b>public</b> <b>fun</b> <b>min</b>(a: u128, b: u128): u128
</code></pre>




<pre><code><b>aborts_if</b> <b>false</b>;
<b>ensures</b> a &lt; b ==&gt; result == a;
<b>ensures</b> a &gt;= b ==&gt; result == b;
</code></pre>



<a name="@Specification_1_average"></a>

### Function `average`


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_average">average</a>(a: u128, b: u128): u128
</code></pre>




<pre><code><b>pragma</b> opaque;
<b>aborts_if</b> <b>false</b>;
<b>ensures</b> result == (a + b) / 2;
</code></pre>



<a name="@Specification_1_pow"></a>

### Function `pow`


<pre><code><b>public</b> <b>fun</b> <a href="math128.md#0x1_math128_pow">pow</a>(n: u128, e: u128): u128
</code></pre>




<pre><code><b>pragma</b> opaque;
<b>aborts_if</b> [abstract] <a href="math128.md#0x1_math128_spec_pow">spec_pow</a>(n, e) &gt; <a href="math128.md#0x1_math128_MAX_U128">MAX_U128</a>;
<b>ensures</b> [abstract] result == <a href="math128.md#0x1_math128_spec_pow">spec_pow</a>(n, e);
</code></pre>




<a name="0x1_math128_spec_pow"></a>


<pre><code><b>fun</b> <a href="math128.md#0x1_math128_spec_pow">spec_pow</a>(e: u128, n: u128): u128 {
   <b>if</b> (e == 0) {
       1
   }
   <b>else</b> {
       n * <a href="math128.md#0x1_math128_spec_pow">spec_pow</a>(n, e-1)
   }
}
</code></pre>


[move-book]: https://move-language.github.io/move/introduction.html
