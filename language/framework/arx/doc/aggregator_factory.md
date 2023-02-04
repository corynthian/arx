
<a name="0x1_aggregator_factory"></a>

# Module `0x1::aggregator_factory`

This module provides foundations to create aggregators. Currently only
Open Libra (0x1) can create them, so this module helps to wrap
the constructor of <code>Aggregator</code> struct so that only a system account
can initialize one. In the future, this might change and aggregators
can be enabled for the public.


-  [Resource `AggregatorFactory`](#0x1_aggregator_factory_AggregatorFactory)
-  [Constants](#@Constants_0)
-  [Function `initialize_aggregator_factory`](#0x1_aggregator_factory_initialize_aggregator_factory)
-  [Function `create_aggregator_internal`](#0x1_aggregator_factory_create_aggregator_internal)
-  [Function `create_aggregator`](#0x1_aggregator_factory_create_aggregator)
-  [Function `new_aggregator`](#0x1_aggregator_factory_new_aggregator)
-  [Specification](#@Specification_1)
    -  [Function `initialize_aggregator_factory`](#@Specification_1_initialize_aggregator_factory)
    -  [Function `create_aggregator_internal`](#@Specification_1_create_aggregator_internal)
    -  [Function `create_aggregator`](#@Specification_1_create_aggregator)
    -  [Function `new_aggregator`](#@Specification_1_new_aggregator)


<pre><code><b>use</b> <a href="aggregator.md#0x1_aggregator">0x1::aggregator</a>;
<b>use</b> <a href="../../std/doc/error.md#0x1_error">0x1::error</a>;
<b>use</b> <a href="system_addresses.md#0x1_system_addresses">0x1::system_addresses</a>;
<b>use</b> <a href="../../std/doc/table.md#0x1_table">0x1::table</a>;
</code></pre>



<a name="0x1_aggregator_factory_AggregatorFactory"></a>

## Resource `AggregatorFactory`

Creates new aggregators. Used to control the numbers of aggregators in the
system and who can create them. At the moment, only Open Libra (0x1)
account can.


<pre><code><b>struct</b> <a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>phantom_table: <a href="../../std/doc/table.md#0x1_table_Table">table::Table</a>&lt;<b>address</b>, u128&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_aggregator_factory_EAGGREGATOR_FACTORY_NOT_FOUND"></a>

Aggregator factory is not published yet.


<pre><code><b>const</b> <a href="aggregator_factory.md#0x1_aggregator_factory_EAGGREGATOR_FACTORY_NOT_FOUND">EAGGREGATOR_FACTORY_NOT_FOUND</a>: u64 = 1;
</code></pre>



<a name="0x1_aggregator_factory_initialize_aggregator_factory"></a>

## Function `initialize_aggregator_factory`

Creates a new factory for aggregators. Can only be called during genesis.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_initialize_aggregator_factory">initialize_aggregator_factory</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_initialize_aggregator_factory">initialize_aggregator_factory</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>) {
    <a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);
    <b>let</b> <a href="aggregator_factory.md#0x1_aggregator_factory">aggregator_factory</a> = <a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a> {
        phantom_table: <a href="../../std/doc/table.md#0x1_table_new">table::new</a>()
    };
    <b>move_to</b>(arx, <a href="aggregator_factory.md#0x1_aggregator_factory">aggregator_factory</a>);
}
</code></pre>



</details>

<a name="0x1_aggregator_factory_create_aggregator_internal"></a>

## Function `create_aggregator_internal`

Creates a new aggregator instance which overflows on exceeding a <code>limit</code>.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_create_aggregator_internal">create_aggregator_internal</a>(limit: u128): <a href="aggregator.md#0x1_aggregator_Aggregator">aggregator::Aggregator</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_create_aggregator_internal">create_aggregator_internal</a>(limit: u128): Aggregator <b>acquires</b> <a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a> {
    <b>assert</b>!(
        <b>exists</b>&lt;<a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a>&gt;(@arx),
        <a href="../../std/doc/error.md#0x1_error_not_found">error::not_found</a>(<a href="aggregator_factory.md#0x1_aggregator_factory_EAGGREGATOR_FACTORY_NOT_FOUND">EAGGREGATOR_FACTORY_NOT_FOUND</a>)
    );

    <b>let</b> <a href="aggregator_factory.md#0x1_aggregator_factory">aggregator_factory</a> = <b>borrow_global_mut</b>&lt;<a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a>&gt;(@arx);
    <a href="aggregator_factory.md#0x1_aggregator_factory_new_aggregator">new_aggregator</a>(<a href="aggregator_factory.md#0x1_aggregator_factory">aggregator_factory</a>, limit)
}
</code></pre>



</details>

<a name="0x1_aggregator_factory_create_aggregator"></a>

## Function `create_aggregator`

This is currently a function closed for public. This can be updated in the future by on-chain
governance to allow any signer to call.


<pre><code><b>public</b> <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_create_aggregator">create_aggregator</a>(<a href="account.md#0x1_account">account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, limit: u128): <a href="aggregator.md#0x1_aggregator_Aggregator">aggregator::Aggregator</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_create_aggregator">create_aggregator</a>(<a href="account.md#0x1_account">account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, limit: u128): Aggregator <b>acquires</b> <a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a> {
    // Only Open Libra (0x1) <a href="account.md#0x1_account">account</a> can call this for now.
    <a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(<a href="account.md#0x1_account">account</a>);
    <a href="aggregator_factory.md#0x1_aggregator_factory_create_aggregator_internal">create_aggregator_internal</a>(limit)
}
</code></pre>



</details>

<a name="0x1_aggregator_factory_new_aggregator"></a>

## Function `new_aggregator`

Returns a new aggregator.


<pre><code><b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_new_aggregator">new_aggregator</a>(<a href="aggregator_factory.md#0x1_aggregator_factory">aggregator_factory</a>: &<b>mut</b> <a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">aggregator_factory::AggregatorFactory</a>, limit: u128): <a href="aggregator.md#0x1_aggregator_Aggregator">aggregator::Aggregator</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_new_aggregator">new_aggregator</a>(<a href="aggregator_factory.md#0x1_aggregator_factory">aggregator_factory</a>: &<b>mut</b> <a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a>, limit: u128): Aggregator;
</code></pre>



</details>

<a name="@Specification_1"></a>

## Specification



<pre><code><b>pragma</b> verify = <b>true</b>;
<b>pragma</b> aborts_if_is_strict;
</code></pre>



<a name="@Specification_1_initialize_aggregator_factory"></a>

### Function `initialize_aggregator_factory`


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_initialize_aggregator_factory">initialize_aggregator_factory</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>


Make sure the caller is @arx.
AggregatorFactory is not under the caller before creating the resource.


<pre><code><b>let</b> addr = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(arx);
<b>aborts_if</b> addr != @arx;
<b>aborts_if</b> <b>exists</b>&lt;<a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a>&gt;(addr);
<b>ensures</b> <b>exists</b>&lt;<a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a>&gt;(addr);
</code></pre>



<a name="@Specification_1_create_aggregator_internal"></a>

### Function `create_aggregator_internal`


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_create_aggregator_internal">create_aggregator_internal</a>(limit: u128): <a href="aggregator.md#0x1_aggregator_Aggregator">aggregator::Aggregator</a>
</code></pre>




<pre><code><b>aborts_if</b> !<b>exists</b>&lt;<a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a>&gt;(@arx);
</code></pre>



<a name="@Specification_1_create_aggregator"></a>

### Function `create_aggregator`


<pre><code><b>public</b> <b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_create_aggregator">create_aggregator</a>(<a href="account.md#0x1_account">account</a>: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, limit: u128): <a href="aggregator.md#0x1_aggregator_Aggregator">aggregator::Aggregator</a>
</code></pre>


Make sure the caller is @arx.
AggregatorFactory existed under the @arx when Creating a new aggregator.


<pre><code><b>let</b> addr = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(<a href="account.md#0x1_account">account</a>);
<b>aborts_if</b> addr != @arx;
<b>aborts_if</b> !<b>exists</b>&lt;<a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">AggregatorFactory</a>&gt;(@arx);
</code></pre>



<a name="@Specification_1_new_aggregator"></a>

### Function `new_aggregator`


<pre><code><b>fun</b> <a href="aggregator_factory.md#0x1_aggregator_factory_new_aggregator">new_aggregator</a>(<a href="aggregator_factory.md#0x1_aggregator_factory">aggregator_factory</a>: &<b>mut</b> <a href="aggregator_factory.md#0x1_aggregator_factory_AggregatorFactory">aggregator_factory::AggregatorFactory</a>, limit: u128): <a href="aggregator.md#0x1_aggregator_Aggregator">aggregator::Aggregator</a>
</code></pre>




<pre><code><b>pragma</b> opaque;
<b>aborts_if</b> <b>false</b>;
<b>ensures</b> result.limit == limit;
</code></pre>


[move-book]: https://move-language.github.io/move/introduction.html
