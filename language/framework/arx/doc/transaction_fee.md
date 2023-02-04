
<a name="0x1_transaction_fee"></a>

# Module `0x1::transaction_fee`

This module provides an interface to burn or collect and redistribute transaction fees.


-  [Resource `ArxCoinCapabilities`](#0x1_transaction_fee_ArxCoinCapabilities)
-  [Resource `CollectedFeesPerBlock`](#0x1_transaction_fee_CollectedFeesPerBlock)
-  [Constants](#@Constants_0)
-  [Function `initialize_fee_collection_and_distribution`](#0x1_transaction_fee_initialize_fee_collection_and_distribution)
-  [Function `is_fees_collection_enabled`](#0x1_transaction_fee_is_fees_collection_enabled)
-  [Function `upgrade_burn_percentage`](#0x1_transaction_fee_upgrade_burn_percentage)
-  [Function `register_proposer_for_fee_collection`](#0x1_transaction_fee_register_proposer_for_fee_collection)
-  [Function `burn_coin_fraction`](#0x1_transaction_fee_burn_coin_fraction)
-  [Function `process_collected_fees`](#0x1_transaction_fee_process_collected_fees)
-  [Function `burn_fee`](#0x1_transaction_fee_burn_fee)
-  [Function `collect_fee`](#0x1_transaction_fee_collect_fee)
-  [Function `store_arx_coin_burn_cap`](#0x1_transaction_fee_store_arx_coin_burn_cap)


<pre><code><b>use</b> <a href="arx_coin.md#0x1_arx_coin">0x1::arx_coin</a>;
<b>use</b> <a href="coin.md#0x1_coin">0x1::coin</a>;
<b>use</b> <a href="../../std/doc/error.md#0x1_error">0x1::error</a>;
<b>use</b> <a href="../../std/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="system_addresses.md#0x1_system_addresses">0x1::system_addresses</a>;
<b>use</b> <a href="validator.md#0x1_validator">0x1::validator</a>;
</code></pre>



<a name="0x1_transaction_fee_ArxCoinCapabilities"></a>

## Resource `ArxCoinCapabilities`

Stores burn capability to burn the gas fees.


<pre><code><b>struct</b> <a href="transaction_fee.md#0x1_transaction_fee_ArxCoinCapabilities">ArxCoinCapabilities</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_transaction_fee_CollectedFeesPerBlock"></a>

## Resource `CollectedFeesPerBlock`

Stores information about the block proposer and the amount of fees
collected when executing the block.


<pre><code><b>struct</b> <a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>amount: <a href="coin.md#0x1_coin_AggregatableCoin">coin::AggregatableCoin</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>proposer: <a href="../../std/doc/option.md#0x1_option_Option">option::Option</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>burn_percentage: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_transaction_fee_EALREADY_CArxLECTING_FEES"></a>

Gas fees are already being collected and the struct holding
information about collected amounts is already published.


<pre><code><b>const</b> <a href="transaction_fee.md#0x1_transaction_fee_EALREADY_CArxLECTING_FEES">EALREADY_CArxLECTING_FEES</a>: u64 = 1;
</code></pre>



<a name="0x1_transaction_fee_EINVALID_BURN_PERCENTAGE"></a>

The burn percentage is out of range [0, 100].


<pre><code><b>const</b> <a href="transaction_fee.md#0x1_transaction_fee_EINVALID_BURN_PERCENTAGE">EINVALID_BURN_PERCENTAGE</a>: u64 = 3;
</code></pre>



<a name="0x1_transaction_fee_initialize_fee_collection_and_distribution"></a>

## Function `initialize_fee_collection_and_distribution`

Initializes the resource storing information about gas fees collection and
distribution. Should be called by on-chain governance.


<pre><code><b>public</b> <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_initialize_fee_collection_and_distribution">initialize_fee_collection_and_distribution</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, burn_percentage: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_initialize_fee_collection_and_distribution">initialize_fee_collection_and_distribution</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, burn_percentage: u8) {
    <a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);
    <b>assert</b>!(
        !<b>exists</b>&lt;<a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a>&gt;(@arx),
        <a href="../../std/doc/error.md#0x1_error_already_exists">error::already_exists</a>(<a href="transaction_fee.md#0x1_transaction_fee_EALREADY_CArxLECTING_FEES">EALREADY_CArxLECTING_FEES</a>)
    );
    <b>assert</b>!(burn_percentage &lt;= 100, <a href="../../std/doc/error.md#0x1_error_out_of_range">error::out_of_range</a>(<a href="transaction_fee.md#0x1_transaction_fee_EINVALID_BURN_PERCENTAGE">EINVALID_BURN_PERCENTAGE</a>));

    // Make sure stakng <b>module</b> is aware of transaction fees collection.
    <a href="validator.md#0x1_validator_initialize_validator_fees">validator::initialize_validator_fees</a>(arx);

    // Initially, no fees are collected and the <a href="block.md#0x1_block">block</a> proposer is not set.
    <b>let</b> collected_fees = <a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a> {
        amount: <a href="coin.md#0x1_coin_initialize_aggregatable_coin">coin::initialize_aggregatable_coin</a>(arx),
        proposer: <a href="../../std/doc/option.md#0x1_option_none">option::none</a>(),
        burn_percentage,
    };
    <b>move_to</b>(arx, collected_fees);
}
</code></pre>



</details>

<a name="0x1_transaction_fee_is_fees_collection_enabled"></a>

## Function `is_fees_collection_enabled`



<pre><code><b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_is_fees_collection_enabled">is_fees_collection_enabled</a>(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_is_fees_collection_enabled">is_fees_collection_enabled</a>(): bool {
    <b>exists</b>&lt;<a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a>&gt;(@arx)
}
</code></pre>



</details>

<a name="0x1_transaction_fee_upgrade_burn_percentage"></a>

## Function `upgrade_burn_percentage`

Sets the burn percentage for collected fees to a new value. Should be called by on-chain governance.


<pre><code><b>public</b> <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_upgrade_burn_percentage">upgrade_burn_percentage</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, new_burn_percentage: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_upgrade_burn_percentage">upgrade_burn_percentage</a>(
    arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>,
    new_burn_percentage: u8
) <b>acquires</b> <a href="transaction_fee.md#0x1_transaction_fee_ArxCoinCapabilities">ArxCoinCapabilities</a>, <a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a> {
    <a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);
    <b>assert</b>!(new_burn_percentage &lt;= 100, <a href="../../std/doc/error.md#0x1_error_out_of_range">error::out_of_range</a>(<a href="transaction_fee.md#0x1_transaction_fee_EINVALID_BURN_PERCENTAGE">EINVALID_BURN_PERCENTAGE</a>));

    // Prior <b>to</b> upgrading the burn percentage, make sure <b>to</b> process collected
    // fees. Otherwise we would <b>use</b> the new (incorrect) burn_percentage when
    // processing fees later!
    <a href="transaction_fee.md#0x1_transaction_fee_process_collected_fees">process_collected_fees</a>();

    <b>if</b> (<a href="transaction_fee.md#0x1_transaction_fee_is_fees_collection_enabled">is_fees_collection_enabled</a>()) {
        // Upgrade <b>has</b> no effect unless fees are being collected.
        <b>let</b> burn_percentage = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a>&gt;(@arx).burn_percentage;
        *burn_percentage = new_burn_percentage
    }
}
</code></pre>



</details>

<a name="0x1_transaction_fee_register_proposer_for_fee_collection"></a>

## Function `register_proposer_for_fee_collection`

Registers the proposer of the block for gas fees collection. This function
can only be called at the beginning of the block.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_register_proposer_for_fee_collection">register_proposer_for_fee_collection</a>(proposer_addr: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_register_proposer_for_fee_collection">register_proposer_for_fee_collection</a>(proposer_addr: <b>address</b>) <b>acquires</b> <a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a> {
    <b>if</b> (<a href="transaction_fee.md#0x1_transaction_fee_is_fees_collection_enabled">is_fees_collection_enabled</a>()) {
        <b>let</b> collected_fees = <b>borrow_global_mut</b>&lt;<a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a>&gt;(@arx);
        <b>let</b> _ = <a href="../../std/doc/option.md#0x1_option_swap_or_fill">option::swap_or_fill</a>(&<b>mut</b> collected_fees.proposer, proposer_addr);
    }
}
</code></pre>



</details>

<a name="0x1_transaction_fee_burn_coin_fraction"></a>

## Function `burn_coin_fraction`

Burns a specified fraction of the coin.


<pre><code><b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_burn_coin_fraction">burn_coin_fraction</a>(<a href="coin.md#0x1_coin">coin</a>: &<b>mut</b> <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;, burn_percentage: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_burn_coin_fraction">burn_coin_fraction</a>(<a href="coin.md#0x1_coin">coin</a>: &<b>mut</b> Coin&lt;ArxCoin&gt;, burn_percentage: u8) <b>acquires</b> <a href="transaction_fee.md#0x1_transaction_fee_ArxCoinCapabilities">ArxCoinCapabilities</a> {
    <b>assert</b>!(burn_percentage &lt;= 100, <a href="../../std/doc/error.md#0x1_error_out_of_range">error::out_of_range</a>(<a href="transaction_fee.md#0x1_transaction_fee_EINVALID_BURN_PERCENTAGE">EINVALID_BURN_PERCENTAGE</a>));

    <b>let</b> collected_amount = <a href="coin.md#0x1_coin_value">coin::value</a>(<a href="coin.md#0x1_coin">coin</a>);
    <b>spec</b> {
        // We <b>assume</b> that `burn_percentage * collected_amount` does not overflow.
        <b>assume</b> burn_percentage * collected_amount &lt;= MAX_U64;
    };
    <b>let</b> amount_to_burn = (burn_percentage <b>as</b> u64) * collected_amount / 100;
    <b>if</b> (amount_to_burn &gt; 0) {
        <b>let</b> coin_to_burn = <a href="coin.md#0x1_coin_extract">coin::extract</a>(<a href="coin.md#0x1_coin">coin</a>, amount_to_burn);
        <a href="coin.md#0x1_coin_burn">coin::burn</a>(
            coin_to_burn,
            &<b>borrow_global</b>&lt;<a href="transaction_fee.md#0x1_transaction_fee_ArxCoinCapabilities">ArxCoinCapabilities</a>&gt;(@arx).burn_cap,
        );
    }
}
</code></pre>



</details>

<a name="0x1_transaction_fee_process_collected_fees"></a>

## Function `process_collected_fees`

Calculates the fee which should be distributed to the block proposer at the
end of an epoch, and records it in the system. This function can only be called
at the beginning of the block or during reconfiguration.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_process_collected_fees">process_collected_fees</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_process_collected_fees">process_collected_fees</a>() <b>acquires</b> <a href="transaction_fee.md#0x1_transaction_fee_ArxCoinCapabilities">ArxCoinCapabilities</a>, <a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a> {
    <b>if</b> (!<a href="transaction_fee.md#0x1_transaction_fee_is_fees_collection_enabled">is_fees_collection_enabled</a>()) {
        <b>return</b>
    };
    <b>let</b> collected_fees = <b>borrow_global_mut</b>&lt;<a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a>&gt;(@arx);

    // If there are no collected fees, only unset the proposer. See the rationale for
    // setting proposer <b>to</b> <a href="../../std/doc/option.md#0x1_option_none">option::none</a>() below.
    <b>if</b> (<a href="coin.md#0x1_coin_is_aggregatable_coin_zero">coin::is_aggregatable_coin_zero</a>(&collected_fees.amount)) {
        <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&collected_fees.proposer)) {
            <b>let</b> _ = <a href="../../std/doc/option.md#0x1_option_extract">option::extract</a>(&<b>mut</b> collected_fees.proposer);
        };
        <b>return</b>
    };

    // Otherwise get the collected fee, and check <b>if</b> it can distributed later.
    <b>let</b> <a href="coin.md#0x1_coin">coin</a> = <a href="coin.md#0x1_coin_drain_aggregatable_coin">coin::drain_aggregatable_coin</a>(&<b>mut</b> collected_fees.amount);
    <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&collected_fees.proposer)) {
        // Extract the <b>address</b> of proposer here and reset it <b>to</b> <a href="../../std/doc/option.md#0x1_option_none">option::none</a>(). This
        // is particularly useful <b>to</b> avoid <a href="../../std/doc/any.md#0x1_any">any</a> undesired side-effects <b>where</b> coins are
        // collected but never distributed or distributed <b>to</b> the wrong <a href="account.md#0x1_account">account</a>.
        // With this design, processing collected fees enforces that all fees will be burnt
        // unless the proposer is specified in the <a href="block.md#0x1_block">block</a> prologue. When we have a <a href="governance.md#0x1_governance">governance</a>
        // proposal that triggers <a href="reconfiguration.md#0x1_reconfiguration">reconfiguration</a>, we distribute pending fees and burn the
        // fee for the proposal. Otherwise, that fee would be leaked <b>to</b> the next <a href="block.md#0x1_block">block</a>.
        <b>let</b> proposer = <a href="../../std/doc/option.md#0x1_option_extract">option::extract</a>(&<b>mut</b> collected_fees.proposer);

        // Since the <a href="block.md#0x1_block">block</a> can be produced by the VM itself, we have <b>to</b> make sure we catch
        // this case.
        <b>if</b> (proposer == @vm_reserved) {
            <a href="transaction_fee.md#0x1_transaction_fee_burn_coin_fraction">burn_coin_fraction</a>(&<b>mut</b> <a href="coin.md#0x1_coin">coin</a>, 100);
            <a href="coin.md#0x1_coin_destroy_zero">coin::destroy_zero</a>(<a href="coin.md#0x1_coin">coin</a>);
            <b>return</b>
        };

        <a href="transaction_fee.md#0x1_transaction_fee_burn_coin_fraction">burn_coin_fraction</a>(&<b>mut</b> <a href="coin.md#0x1_coin">coin</a>, collected_fees.burn_percentage);
	    // ARX-TODO: Investigate fees
        <a href="validator.md#0x1_validator_add_transaction_fee">validator::add_transaction_fee</a>(proposer, <a href="coin.md#0x1_coin">coin</a>);
        <b>return</b>
    };

    // If checks did not pass, simply burn all collected coins and <b>return</b> none.
    <a href="transaction_fee.md#0x1_transaction_fee_burn_coin_fraction">burn_coin_fraction</a>(&<b>mut</b> <a href="coin.md#0x1_coin">coin</a>, 100);
    <a href="coin.md#0x1_coin_destroy_zero">coin::destroy_zero</a>(<a href="coin.md#0x1_coin">coin</a>)
}
</code></pre>



</details>

<a name="0x1_transaction_fee_burn_fee"></a>

## Function `burn_fee`

Burn transaction fees in epilogue.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_burn_fee">burn_fee</a>(<a href="account.md#0x1_account">account</a>: <b>address</b>, fee: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_burn_fee">burn_fee</a>(<a href="account.md#0x1_account">account</a>: <b>address</b>, fee: u64) <b>acquires</b> <a href="transaction_fee.md#0x1_transaction_fee_ArxCoinCapabilities">ArxCoinCapabilities</a> {
    <a href="coin.md#0x1_coin_burn_from">coin::burn_from</a>&lt;ArxCoin&gt;(
        <a href="account.md#0x1_account">account</a>,
        fee,
        &<b>borrow_global</b>&lt;<a href="transaction_fee.md#0x1_transaction_fee_ArxCoinCapabilities">ArxCoinCapabilities</a>&gt;(@arx).burn_cap,
    );
}
</code></pre>



</details>

<a name="0x1_transaction_fee_collect_fee"></a>

## Function `collect_fee`

Collect transaction fees in epilogue.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_collect_fee">collect_fee</a>(<a href="account.md#0x1_account">account</a>: <b>address</b>, fee: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_collect_fee">collect_fee</a>(<a href="account.md#0x1_account">account</a>: <b>address</b>, fee: u64) <b>acquires</b> <a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a> {
    <b>let</b> collected_fees = <b>borrow_global_mut</b>&lt;<a href="transaction_fee.md#0x1_transaction_fee_CollectedFeesPerBlock">CollectedFeesPerBlock</a>&gt;(@arx);

    // Here, we are always optimistic and always collect fees. If the proposer is not set,
    // or we cannot redistribute fees later for some reason (e.g. <a href="account.md#0x1_account">account</a> cannot receive AptoCoin)
    // we burn them all at once. This way we avoid having a check for every transaction epilogue.
    <b>let</b> collected_amount = &<b>mut</b> collected_fees.amount;
    <a href="coin.md#0x1_coin_collect_into_aggregatable_coin">coin::collect_into_aggregatable_coin</a>&lt;ArxCoin&gt;(<a href="account.md#0x1_account">account</a>, fee, collected_amount);
}
</code></pre>



</details>

<a name="0x1_transaction_fee_store_arx_coin_burn_cap"></a>

## Function `store_arx_coin_burn_cap`

Only called during genesis.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_store_arx_coin_burn_cap">store_arx_coin_burn_cap</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, burn_cap: <a href="coin.md#0x1_coin_BurnCapability">coin::BurnCapability</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x1_transaction_fee_store_arx_coin_burn_cap">store_arx_coin_burn_cap</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, burn_cap: BurnCapability&lt;ArxCoin&gt;) {
    <a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);
    <b>move_to</b>(arx, <a href="transaction_fee.md#0x1_transaction_fee_ArxCoinCapabilities">ArxCoinCapabilities</a> { burn_cap })
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
