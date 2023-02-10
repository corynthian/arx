
<a name="0x1_delta"></a>

# Module `0x1::delta`



-  [Struct `Delta`](#0x1_delta_Delta)
-  [Constants](#@Constants_0)
-  [Function `create`](#0x1_delta_create)
-  [Function `get_delta_sign`](#0x1_delta_get_delta_sign)
-  [Function `get_delta_value`](#0x1_delta_get_delta_value)


<pre><code></code></pre>



<a name="0x1_delta_Delta"></a>

## Struct `Delta`

Represents the time weighted average reserve of X in the last epoch.


<pre><code><b>struct</b> <a href="delta.md#0x1_delta_Delta">Delta</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>sign: u64</code>
</dt>
<dd>
 Whether X > Y, Y > X or X = Y
</dd>
<dt>
<code>value: u64</code>
</dt>
<dd>
 The cumulative difference in X vs Y
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_delta_DELTA_EQUAL"></a>

Delta zero


<pre><code><b>const</b> <a href="delta.md#0x1_delta_DELTA_EQUAL">DELTA_EQUAL</a>: u64 = 0;
</code></pre>



<a name="0x1_delta_DELTA_NEGATIVE"></a>

Delta negative sign


<pre><code><b>const</b> <a href="delta.md#0x1_delta_DELTA_NEGATIVE">DELTA_NEGATIVE</a>: u64 = 2;
</code></pre>



<a name="0x1_delta_DELTA_POSITIVE"></a>

Delta positive sign


<pre><code><b>const</b> <a href="delta.md#0x1_delta_DELTA_POSITIVE">DELTA_POSITIVE</a>: u64 = 1;
</code></pre>



<a name="0x1_delta_create"></a>

## Function `create`



<pre><code><b>public</b> <b>fun</b> <a href="delta.md#0x1_delta_create">create</a>(sign: u64, value: u64): <a href="delta.md#0x1_delta_Delta">delta::Delta</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="delta.md#0x1_delta_create">create</a>(sign: u64, value: u64): <a href="delta.md#0x1_delta_Delta">Delta</a> {
	<a href="delta.md#0x1_delta_Delta">Delta</a> { sign, value }
}
</code></pre>



</details>

<a name="0x1_delta_get_delta_sign"></a>

## Function `get_delta_sign`



<pre><code><b>public</b> <b>fun</b> <a href="delta.md#0x1_delta_get_delta_sign">get_delta_sign</a>(<a href="delta.md#0x1_delta">delta</a>: &<a href="delta.md#0x1_delta_Delta">delta::Delta</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="delta.md#0x1_delta_get_delta_sign">get_delta_sign</a>(<a href="delta.md#0x1_delta">delta</a>: &<a href="delta.md#0x1_delta_Delta">Delta</a>): u64 {
	<a href="delta.md#0x1_delta">delta</a>.sign
}
</code></pre>



</details>

<a name="0x1_delta_get_delta_value"></a>

## Function `get_delta_value`



<pre><code><b>public</b> <b>fun</b> <a href="delta.md#0x1_delta_get_delta_value">get_delta_value</a>(<a href="delta.md#0x1_delta">delta</a>: &<a href="delta.md#0x1_delta_Delta">delta::Delta</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="delta.md#0x1_delta_get_delta_value">get_delta_value</a>(<a href="delta.md#0x1_delta">delta</a>: &<a href="delta.md#0x1_delta_Delta">Delta</a>): u64 {
	<a href="delta.md#0x1_delta">delta</a>.value
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
