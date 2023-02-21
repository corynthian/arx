
<a name="0x1_subsidialis"></a>

# Module `0x1::subsidialis`



-  [Resource `Subsidialis`](#0x1_subsidialis_Subsidialis)
-  [Resource `SubsidialisEvents`](#0x1_subsidialis_SubsidialisEvents)
-  [Struct `SubsidialisInitializedEvent`](#0x1_subsidialis_SubsidialisInitializedEvent)
-  [Struct `SubsidialisJoinEvent`](#0x1_subsidialis_SubsidialisJoinEvent)
-  [Struct `SubsidialisLeaveEvent`](#0x1_subsidialis_SubsidialisLeaveEvent)
-  [Struct `SubsidialisReconfigurationEvent`](#0x1_subsidialis_SubsidialisReconfigurationEvent)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_subsidialis_initialize)
-  [Function `join`](#0x1_subsidialis_join)
-  [Function `leave`](#0x1_subsidialis_leave)
-  [Function `on_new_epoch`](#0x1_subsidialis_on_new_epoch)
-  [Function `distribute_mints`](#0x1_subsidialis_distribute_mints)
-  [Function `add_coins`](#0x1_subsidialis_add_coins)
-  [Function `increase_joining_power`](#0x1_subsidialis_increase_joining_power)
-  [Function `is_active_dominus`](#0x1_subsidialis_is_active_dominus)
-  [Function `get_dominus_state`](#0x1_subsidialis_get_dominus_state)
-  [Function `find_dominus`](#0x1_subsidialis_find_dominus)
-  [Function `get_total_active_power`](#0x1_subsidialis_get_total_active_power)
-  [Function `assert_exists`](#0x1_subsidialis_assert_exists)
-  [Function `assert_solaris_exists`](#0x1_subsidialis_assert_solaris_exists)


<pre><code><b>use</b> <a href="account.md#0x1_account">0x1::account</a>;
<b>use</b> <a href="arx_coin.md#0x1_arx_coin">0x1::arx_coin</a>;
<b>use</b> <a href="coin.md#0x1_coin">0x1::coin</a>;
<b>use</b> <a href="../../std/doc/error.md#0x1_error">0x1::error</a>;
<b>use</b> <a href="event.md#0x1_event">0x1::event</a>;
<b>use</b> <a href="../../std/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../std/doc/signer.md#0x1_signer">0x1::signer</a>;
<b>use</b> <a href="solaris.md#0x1_solaris">0x1::solaris</a>;
<b>use</b> <a href="system_addresses.md#0x1_system_addresses">0x1::system_addresses</a>;
<b>use</b> <a href="../../std/doc/uq64x64.md#0x1_uq64x64">0x1::uq64x64</a>;
<b>use</b> <a href="../../std/doc/vector.md#0x1_vector">0x1::vector</a>;
</code></pre>



<a name="0x1_subsidialis_Subsidialis"></a>

## Resource `Subsidialis`

The set of solaris managed by the @arx subsidialis.
1. join adds to the pending_active subsidialis queue.
2. leave moves active to the pending_inactive subsidialis queue.
3. on_new_epoch processes the two pending queues.


<pre><code><b>struct</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>active: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>
 The active domini of the current epoch.
</dd>
<dt>
<code>pending_inactive: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>
 Dominus leaving in the next epoch.
</dd>
<dt>
<code>pending_active: <a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>
 Dominus joining in the next epoch.
</dd>
<dt>
<code>total_active_power: u128</code>
</dt>
<dd>
 The total lux active in the subsidialis.
</dd>
<dt>
<code>total_joining_power: u128</code>
</dt>
<dd>
 The total lux waiting to join.
</dd>
</dl>


</details>

<a name="0x1_subsidialis_SubsidialisEvents"></a>

## Resource `SubsidialisEvents`

Stores the event handles of the subsidialis.


<pre><code><b>struct</b> <a href="subsidialis.md#0x1_subsidialis_SubsidialisEvents">SubsidialisEvents</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>subsidialis_initialized_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="subsidialis.md#0x1_subsidialis_SubsidialisInitializedEvent">subsidialis::SubsidialisInitializedEvent</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>subsidialis_join_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="subsidialis.md#0x1_subsidialis_SubsidialisJoinEvent">subsidialis::SubsidialisJoinEvent</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>subsidialis_leave_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="subsidialis.md#0x1_subsidialis_SubsidialisLeaveEvent">subsidialis::SubsidialisLeaveEvent</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>subsidialis_reconfiguration_events: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="subsidialis.md#0x1_subsidialis_SubsidialisReconfigurationEvent">subsidialis::SubsidialisReconfigurationEvent</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_subsidialis_SubsidialisInitializedEvent"></a>

## Struct `SubsidialisInitializedEvent`

Triggers when the subsidialis has been initialized.


<pre><code><b>struct</b> <a href="subsidialis.md#0x1_subsidialis_SubsidialisInitializedEvent">SubsidialisInitializedEvent</a> <b>has</b> drop, store
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

<a name="0x1_subsidialis_SubsidialisJoinEvent"></a>

## Struct `SubsidialisJoinEvent`

Triggers when a solaris owner becomes a dominus by joining the subsidialis.


<pre><code><b>struct</b> <a href="subsidialis.md#0x1_subsidialis_SubsidialisJoinEvent">SubsidialisJoinEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>solaris_address: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_subsidialis_SubsidialisLeaveEvent"></a>

## Struct `SubsidialisLeaveEvent`

Triggers when a subsidialis member revokes their membership.


<pre><code><b>struct</b> <a href="subsidialis.md#0x1_subsidialis_SubsidialisLeaveEvent">SubsidialisLeaveEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>solaris_address: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_subsidialis_SubsidialisReconfigurationEvent"></a>

## Struct `SubsidialisReconfigurationEvent`

Triggers when a new epoch causes the subsidialis to reconfigure itself.


<pre><code><b>struct</b> <a href="subsidialis.md#0x1_subsidialis_SubsidialisReconfigurationEvent">SubsidialisReconfigurationEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>total_active_power: u128</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_subsidialis_DOMINUS_STATUS_ACTIVE"></a>

Dominus is actively receiving rewards.


<pre><code><b>const</b> <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_ACTIVE">DOMINUS_STATUS_ACTIVE</a>: u64 = 2;
</code></pre>



<a name="0x1_subsidialis_DOMINUS_STATUS_INACTIVE"></a>

Dominus is not an active participant.


<pre><code><b>const</b> <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_INACTIVE">DOMINUS_STATUS_INACTIVE</a>: u64 = 4;
</code></pre>



<a name="0x1_subsidialis_DOMINUS_STATUS_PENDING_ACTIVE"></a>

Dominus is waiting to join the set.


<pre><code><b>const</b> <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_PENDING_ACTIVE">DOMINUS_STATUS_PENDING_ACTIVE</a>: u64 = 1;
</code></pre>



<a name="0x1_subsidialis_DOMINUS_STATUS_PENDING_INACTIVE"></a>

Dominus is waiting to withdraw forma coins.


<pre><code><b>const</b> <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_PENDING_INACTIVE">DOMINUS_STATUS_PENDING_INACTIVE</a>: u64 = 3;
</code></pre>



<a name="0x1_subsidialis_EDOMINUS_ALREADY_ACTIVE"></a>

Attempted to active an already active dominus.


<pre><code><b>const</b> <a href="subsidialis.md#0x1_subsidialis_EDOMINUS_ALREADY_ACTIVE">EDOMINUS_ALREADY_ACTIVE</a>: u64 = 2;
</code></pre>



<a name="0x1_subsidialis_EDOMINUS_ALREADY_INACTIVE"></a>

Attempted to deactivate an already inactive dominus.


<pre><code><b>const</b> <a href="subsidialis.md#0x1_subsidialis_EDOMINUS_ALREADY_INACTIVE">EDOMINUS_ALREADY_INACTIVE</a>: u64 = 3;
</code></pre>



<a name="0x1_subsidialis_ESOLARIS_DOES_NOT_EXIST"></a>

Attempted to use a non existent solaris position.


<pre><code><b>const</b> <a href="subsidialis.md#0x1_subsidialis_ESOLARIS_DOES_NOT_EXIST">ESOLARIS_DOES_NOT_EXIST</a>: u64 = 4;
</code></pre>



<a name="0x1_subsidialis_ESUBSIDIALIS_NOT_FOUND"></a>

The subsidialis was not initialized.


<pre><code><b>const</b> <a href="subsidialis.md#0x1_subsidialis_ESUBSIDIALIS_NOT_FOUND">ESUBSIDIALIS_NOT_FOUND</a>: u64 = 1;
</code></pre>



<a name="0x1_subsidialis_initialize"></a>

## Function `initialize`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_initialize">initialize</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_initialize">initialize</a>(arx: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>) {
	<a href="system_addresses.md#0x1_system_addresses_assert_arx">system_addresses::assert_arx</a>(arx);
	<b>move_to</b>(arx, <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a> {
	    active: <a href="../../std/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
	    pending_inactive: <a href="../../std/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
	    pending_active: <a href="../../std/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
	    total_active_power: 0,
	    total_joining_power: 0,
	});
	<b>let</b> subsidialis_events = <a href="subsidialis.md#0x1_subsidialis_SubsidialisEvents">SubsidialisEvents</a> {
	    subsidialis_initialized_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(arx),
	    subsidialis_join_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(arx),
	    subsidialis_leave_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(arx),
	    subsidialis_reconfiguration_events: <a href="account.md#0x1_account_new_event_handle">account::new_event_handle</a>(arx),
	};
	<a href="event.md#0x1_event_emit_event">event::emit_event</a>(
	    &<b>mut</b> subsidialis_events.subsidialis_initialized_events,
	    <a href="subsidialis.md#0x1_subsidialis_SubsidialisInitializedEvent">SubsidialisInitializedEvent</a> {},
	);
	<b>move_to</b>(arx, subsidialis_events);
}
</code></pre>



</details>

<a name="0x1_subsidialis_join"></a>

## Function `join`

Join the subsidialis with a pre-existing solaris of designated coin type.
It is necessary to join the subsidialis in order to receive seignorage rewards.


<pre><code><b>public</b> entry <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_join">join</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_join">join</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
	<b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>, <a href="subsidialis.md#0x1_subsidialis_SubsidialisEvents">SubsidialisEvents</a>
{
	<b>let</b> solaris_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);

	// TODO: Ensure the <a href="solaris.md#0x1_solaris">solaris</a> is not in <a href="senatus.md#0x1_senatus">senatus</a>.

	// If a <a href="solaris.md#0x1_solaris">solaris</a> for the provided `CoinType` does not exist, then create one.
	<b>if</b> (!<a href="solaris.md#0x1_solaris_exists_cointype">solaris::exists_cointype</a>&lt;CoinType&gt;(solaris_address)) {
	    <a href="solaris.md#0x1_solaris_initialize_owner">solaris::initialize_owner</a>&lt;CoinType&gt;(owner);
	};

	// Ensure the <a href="solaris.md#0x1_solaris">solaris</a> is not already an active dominus.
	<b>assert</b>!(
	    <a href="subsidialis.md#0x1_subsidialis_get_dominus_state">get_dominus_state</a>(solaris_address) == <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_INACTIVE">DOMINUS_STATUS_INACTIVE</a>,
	    <a href="../../std/doc/error.md#0x1_error_invalid_state">error::invalid_state</a>(<a href="subsidialis.md#0x1_subsidialis_EDOMINUS_ALREADY_ACTIVE">EDOMINUS_ALREADY_ACTIVE</a>),
	);

	// Push the <a href="solaris.md#0x1_solaris">solaris</a> <b>address</b> <b>to</b> the pending active set.
	<b>let</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> = <b>borrow_global_mut</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx);
	<a href="../../std/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_active, solaris_address);

	<b>let</b> subsidialis_events = <b>borrow_global_mut</b>&lt;<a href="subsidialis.md#0x1_subsidialis_SubsidialisEvents">SubsidialisEvents</a>&gt;(@arx);
	<a href="event.md#0x1_event_emit_event">event::emit_event</a>(
	    &<b>mut</b> subsidialis_events.subsidialis_join_events,
	    <a href="subsidialis.md#0x1_subsidialis_SubsidialisJoinEvent">SubsidialisJoinEvent</a> {
		solaris_address,
	    },
	);
}
</code></pre>



</details>

<a name="0x1_subsidialis_leave"></a>

## Function `leave`

Leave the subsidialis with a pre-existing solaris of designated coin type.
It is necessary to leave the subsidialis in order for removed forma coins to become unlocked.


<pre><code><b>public</b> entry <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_leave">leave</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_leave">leave</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>)
	<b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>, <a href="subsidialis.md#0x1_subsidialis_SubsidialisEvents">SubsidialisEvents</a>
{
	<b>let</b> solaris_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);
	// Ensure a <a href="solaris.md#0x1_solaris">solaris</a> <b>exists</b> at the supplied <b>address</b>.
	<a href="solaris.md#0x1_solaris_assert_exists">solaris::assert_exists</a>&lt;CoinType&gt;(solaris_address);

	// Ensure the owner of this <a href="solaris.md#0x1_solaris">solaris</a> is an active member.
	<b>assert</b>!(
	    <a href="subsidialis.md#0x1_subsidialis_get_dominus_state">get_dominus_state</a>(solaris_address) == <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_ACTIVE">DOMINUS_STATUS_ACTIVE</a>,
	    <a href="../../std/doc/error.md#0x1_error_invalid_state">error::invalid_state</a>(<a href="subsidialis.md#0x1_subsidialis_EDOMINUS_ALREADY_INACTIVE">EDOMINUS_ALREADY_INACTIVE</a>),
	);

	// Push the <a href="solaris.md#0x1_solaris">solaris</a> <b>address</b> <b>to</b> the pending inactive set.
	<b>let</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> = <b>borrow_global_mut</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx);
	<a href="../../std/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_inactive, solaris_address);

	<b>let</b> subsidialis_events = <b>borrow_global_mut</b>&lt;<a href="subsidialis.md#0x1_subsidialis_SubsidialisEvents">SubsidialisEvents</a>&gt;(@arx);
	<a href="event.md#0x1_event_emit_event">event::emit_event</a>(
	    &<b>mut</b> subsidialis_events.subsidialis_leave_events,
	    <a href="subsidialis.md#0x1_subsidialis_SubsidialisLeaveEvent">SubsidialisLeaveEvent</a> {
		solaris_address,
	    },
	);
}
</code></pre>



</details>

<a name="0x1_subsidialis_on_new_epoch"></a>

## Function `on_new_epoch`

Triggers at reconfiguration. This function should not abort.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_on_new_epoch">on_new_epoch</a>&lt;CoinType&gt;()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_on_new_epoch">on_new_epoch</a>&lt;CoinType&gt;()
	<b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>, <a href="subsidialis.md#0x1_subsidialis_SubsidialisEvents">SubsidialisEvents</a>
{
	<a href="subsidialis.md#0x1_subsidialis_assert_exists">assert_exists</a>();
	<b>let</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> = <b>borrow_global_mut</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx);

	// Update seignorage rewards for each active member.
	<b>let</b> i = 0;
	<b>let</b> vlen = <a href="../../std/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active);
	<b>while</b> (i &lt; vlen) {
	    <b>let</b> solaris_address = *<a href="../../std/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active, i);
	    <a href="solaris.md#0x1_solaris_on_subsidialis_update">solaris::on_subsidialis_update</a>&lt;CoinType&gt;(solaris_address);
	    i = i + 1;
	};

	// Activate currently pending_active members.
    <a href="../../std/doc/vector.md#0x1_vector_append_nondestructive">vector::append_nondestructive</a>(&<b>mut</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active, &<b>mut</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_active);

	// Unlock pending_unlocked <a href="forma.md#0x1_forma">forma</a> coins within the solarii.
	<b>let</b> subsidialis_lux_power = 0;
	<b>let</b> i = 0;
	<b>let</b> vlen = <a href="../../std/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_inactive);
	<b>while</b> (i &lt; vlen) {
	    <b>let</b> solaris_address = *<a href="../../std/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_inactive, i);
	    <a href="solaris.md#0x1_solaris_on_subsidialis_deactivate">solaris::on_subsidialis_deactivate</a>&lt;CoinType&gt;(solaris_address);
	    // Subtract the active lux power of the <a href="solaris.md#0x1_solaris">solaris</a> from the total active power.
	    <b>let</b> active_lux_value = <a href="solaris.md#0x1_solaris_get_active_lux_value">solaris::get_active_lux_value</a>&lt;CoinType&gt;(solaris_address);
	    subsidialis_lux_power = subsidialis_lux_power + active_lux_value;
	    i = i + 1;
	};
	// Set pending_inactive <b>to</b> () since they have been deactivated.
	<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_inactive = <a href="../../std/doc/vector.md#0x1_vector_empty">vector::empty</a>();
	<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_active_power =
	    <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_active_power - (subsidialis_lux_power <b>as</b> u128);

	// Compute the total lux power and set joining power <b>to</b> 0.
	<b>let</b> subsidialis_lux_power = 0;
	<b>let</b> i = 0;
	<b>let</b> vlen = <a href="../../std/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active);
	<b>while</b> (i &lt; vlen) {
	    <b>let</b> solaris_address = *<a href="../../std/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active, i);
	    <b>let</b> active_lux_value = <a href="solaris.md#0x1_solaris_get_active_lux_value">solaris::get_active_lux_value</a>&lt;CoinType&gt;(solaris_address);
	    subsidialis_lux_power = subsidialis_lux_power + active_lux_value;
	    // TODO: renew_timelock();
	    i = i + 1;
	};
	// IMPORTANT: The total lux power *must* be set <b>to</b> 0 prior <b>to</b> calling `on_new_epoch` <b>with</b>
	// different <a href="coin.md#0x1_coin">coin</a> types.
	<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_active_power =
	    <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_active_power + (subsidialis_lux_power <b>as</b> u128);

	<b>let</b> subsidialis_events = <b>borrow_global_mut</b>&lt;<a href="subsidialis.md#0x1_subsidialis_SubsidialisEvents">SubsidialisEvents</a>&gt;(@arx);
	<a href="event.md#0x1_event_emit_event">event::emit_event</a>(
	    &<b>mut</b> subsidialis_events.subsidialis_reconfiguration_events,
	    <a href="subsidialis.md#0x1_subsidialis_SubsidialisReconfigurationEvent">SubsidialisReconfigurationEvent</a> {
		total_active_power: <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_active_power,
	    },
	);
}
</code></pre>



</details>

<a name="0x1_subsidialis_distribute_mints"></a>

## Function `distribute_mints`

Distribute moneta mints to the solaris set.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_distribute_mints">distribute_mints</a>&lt;CoinType&gt;(coins: <a href="coin.md#0x1_coin_Coin">coin::Coin</a>&lt;<a href="arx_coin.md#0x1_arx_coin_ArxCoin">arx_coin::ArxCoin</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_distribute_mints">distribute_mints</a>&lt;CoinType&gt;(coins: Coin&lt;ArxCoin&gt;) <b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a> {
	<a href="subsidialis.md#0x1_subsidialis_assert_exists">assert_exists</a>();
	<b>let</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> = <b>borrow_global</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx);
	// FIXME: (downcasting) Update <a href="forma.md#0x1_forma">forma</a> rewards for each active member.
	<b>let</b> total_power = (<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_active_power <b>as</b> u64);
	<b>let</b> i = 0;
	<b>let</b> vlen = <a href="../../std/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active);
	<b>while</b> (i &lt; vlen) {
	    <b>let</b> solaris_address = *<a href="../../std/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active, i);
	    // Compute the share which this active <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> is owed.
	    <b>let</b> active_lux_value = <a href="solaris.md#0x1_solaris_get_active_lux_value">solaris::get_active_lux_value</a>&lt;CoinType&gt;(solaris_address);
	    <b>let</b> active_lux_share = <a href="../../std/doc/uq64x64.md#0x1_uq64x64_decode">uq64x64::decode</a>(<a href="../../std/doc/uq64x64.md#0x1_uq64x64_fraction">uq64x64::fraction</a>(active_lux_value, total_power));
	    <b>let</b> coin_share = active_lux_share * <a href="coin.md#0x1_coin_value">coin::value</a>(&coins);
	    <b>let</b> coins = <a href="coin.md#0x1_coin_extract">coin::extract</a>(&<b>mut</b> coins, coin_share);
	    // Deposit the mints directly in the <a href="solaris.md#0x1_solaris">solaris</a> (owners) <a href="account.md#0x1_account">account</a>.
	    <a href="coin.md#0x1_coin_deposit">coin::deposit</a>(solaris_address, coins);
	    i = i + 1;
	};
	// Should fail <b>if</b> the mints were not rewarded fully.
	<a href="coin.md#0x1_coin_destroy_zero">coin::destroy_zero</a>&lt;ArxCoin&gt;(coins);
}
</code></pre>



</details>

<a name="0x1_subsidialis_add_coins"></a>

## Function `add_coins`

Adds coins to a dominuses solaris.


<pre><code><b>public</b> entry <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_add_coins">add_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_add_coins">add_coins</a>&lt;CoinType&gt;(owner: &<a href="../../std/doc/signer.md#0x1_signer">signer</a>, amount: u64)
	<b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>
{
	<b>let</b> dominus_address = <a href="../../std/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(owner);

	// Ensure a <a href="solaris.md#0x1_solaris">solaris</a> <b>exists</b> at the supplied <b>address</b> (created by joining the <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>).
	<a href="solaris.md#0x1_solaris_assert_exists">solaris::assert_exists</a>&lt;CoinType&gt;(dominus_address);

	// Add coins and add pending_active seignorage <b>if</b> the dominus is currently active in order <b>to</b>
	// make the seignorage count in the next epoch. If the dominus is not yet active then the
	// seignorage can be immediately added <b>to</b> active, since they will activate in the next epoch.
	<b>if</b> (<a href="subsidialis.md#0x1_subsidialis_is_active_dominus">is_active_dominus</a>(dominus_address)) {
	    <a href="solaris.md#0x1_solaris_add_pending_coins">solaris::add_pending_coins</a>&lt;CoinType&gt;(owner, amount);
	} <b>else</b> {
	    <a href="solaris.md#0x1_solaris_add_active_coins">solaris::add_active_coins</a>&lt;CoinType&gt;(owner, amount);
	};

    // Only track and validate lux power increases for active and pending_active domini.
    // pending_inactive dominui will be removed from the <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> in the next epoch.
    // Inactive domini total stake will be tracked when they join the <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.
    <b>let</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> = <b>borrow_global_mut</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx);
    // Search directly rather using get_archon_state <b>to</b> save on unnecessary loops.
    <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="subsidialis.md#0x1_subsidialis_find_dominus">find_dominus</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active, dominus_address)) ||
        <a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="subsidialis.md#0x1_subsidialis_find_dominus">find_dominus</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_active, dominus_address))) {
        <a href="subsidialis.md#0x1_subsidialis_increase_joining_power">increase_joining_power</a>(amount);
    };
}
</code></pre>



</details>

<a name="0x1_subsidialis_increase_joining_power"></a>

## Function `increase_joining_power`



<pre><code><b>fun</b> <a href="subsidialis.md#0x1_subsidialis_increase_joining_power">increase_joining_power</a>(amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="subsidialis.md#0x1_subsidialis_increase_joining_power">increase_joining_power</a>(amount: u64) <b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a> {
	<b>let</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> = <b>borrow_global_mut</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx);
	<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_joining_power = <a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_joining_power + (amount <b>as</b> u128);
	// TODO: Check for minimum / maximum power
}
</code></pre>



</details>

<a name="0x1_subsidialis_is_active_dominus"></a>

## Function `is_active_dominus`

Returns true is the specified archon is still participating in the subsidialis.
This includes domini which have requested to leave but are pending inactive.


<pre><code><b>public</b> <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_is_active_dominus">is_active_dominus</a>(dominus_address: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_is_active_dominus">is_active_dominus</a>(dominus_address: <b>address</b>): bool <b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a> {
	<a href="subsidialis.md#0x1_subsidialis_assert_solaris_exists">assert_solaris_exists</a>(dominus_address);
	<b>let</b> dominus_state = <a href="subsidialis.md#0x1_subsidialis_get_dominus_state">get_dominus_state</a>(dominus_address);
	dominus_state == <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_ACTIVE">DOMINUS_STATUS_ACTIVE</a> || dominus_state == <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_PENDING_INACTIVE">DOMINUS_STATUS_PENDING_INACTIVE</a>
}
</code></pre>



</details>

<a name="0x1_subsidialis_get_dominus_state"></a>

## Function `get_dominus_state`

Returns the state of an dominus.


<pre><code><b>public</b> <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_get_dominus_state">get_dominus_state</a>(lock_address: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_get_dominus_state">get_dominus_state</a>(lock_address: <b>address</b>): u64
	<b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>
{
	<b>let</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> = <b>borrow_global</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx);
	<b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="subsidialis.md#0x1_subsidialis_find_dominus">find_dominus</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_active, lock_address))) {
	    <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_PENDING_ACTIVE">DOMINUS_STATUS_PENDING_ACTIVE</a>
    } <b>else</b> <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="subsidialis.md#0x1_subsidialis_find_dominus">find_dominus</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.active, lock_address))) {
	    <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_ACTIVE">DOMINUS_STATUS_ACTIVE</a>
    } <b>else</b> <b>if</b> (<a href="../../std/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="subsidialis.md#0x1_subsidialis_find_dominus">find_dominus</a>(&<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.pending_inactive, lock_address))) {
	    <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_PENDING_INACTIVE">DOMINUS_STATUS_PENDING_INACTIVE</a>
    } <b>else</b> {
	    <a href="subsidialis.md#0x1_subsidialis_DOMINUS_STATUS_INACTIVE">DOMINUS_STATUS_INACTIVE</a>
    }
}
</code></pre>



</details>

<a name="0x1_subsidialis_find_dominus"></a>

## Function `find_dominus`

Finds the current status of a designated dominus by lock address.


<pre><code><b>fun</b> <a href="subsidialis.md#0x1_subsidialis_find_dominus">find_dominus</a>(v: &<a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<b>address</b>&gt;, <b>address</b>: <b>address</b>): <a href="../../std/doc/option.md#0x1_option_Option">option::Option</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="subsidialis.md#0x1_subsidialis_find_dominus">find_dominus</a>(v: &<a href="../../std/doc/vector.md#0x1_vector">vector</a>&lt;<b>address</b>&gt;, <b>address</b>: <b>address</b>): Option&lt;u64&gt; {
    <b>let</b> i = 0;
    <b>let</b> vlen = <a href="../../std/doc/vector.md#0x1_vector_length">vector::length</a>(v);
    <b>while</b> ({
        <b>spec</b> {
            <b>invariant</b> !(<b>exists</b> j in 0..i: v[j] == <b>address</b>);
        };
        i &lt; vlen
    }) {
        <b>if</b> (*<a href="../../std/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(v, i) == <b>address</b>) {
            <b>return</b> <a href="../../std/doc/option.md#0x1_option_some">option::some</a>(i)
        };
        i = i + 1;
    };
    <a href="../../std/doc/option.md#0x1_option_none">option::none</a>()
}
</code></pre>



</details>

<a name="0x1_subsidialis_get_total_active_power"></a>

## Function `get_total_active_power`

Get the total active lux power.


<pre><code><b>public</b> <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_get_total_active_power">get_total_active_power</a>&lt;CoinType&gt;(): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_get_total_active_power">get_total_active_power</a>&lt;CoinType&gt;(): u128
	<b>acquires</b> <a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>
{
	<b>let</b> <a href="subsidialis.md#0x1_subsidialis">subsidialis</a> = <b>borrow_global</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx);
	<a href="subsidialis.md#0x1_subsidialis">subsidialis</a>.total_active_power
}
</code></pre>



</details>

<a name="0x1_subsidialis_assert_exists"></a>

## Function `assert_exists`

Ensures the subsidialis exists.


<pre><code><b>public</b> <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_assert_exists">assert_exists</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="subsidialis.md#0x1_subsidialis_assert_exists">assert_exists</a>() {
	<b>assert</b>!(<b>exists</b>&lt;<a href="subsidialis.md#0x1_subsidialis_Subsidialis">Subsidialis</a>&gt;(@arx), <a href="../../std/doc/error.md#0x1_error_not_found">error::not_found</a>(<a href="subsidialis.md#0x1_subsidialis_ESUBSIDIALIS_NOT_FOUND">ESUBSIDIALIS_NOT_FOUND</a>));
}
</code></pre>



</details>

<a name="0x1_subsidialis_assert_solaris_exists"></a>

## Function `assert_solaris_exists`

Ensures a solaris exists of either ArxCoin or LP<ArxCoin, XUSDCoin, Stable> at the supplied
address.


<pre><code><b>fun</b> <a href="subsidialis.md#0x1_subsidialis_assert_solaris_exists">assert_solaris_exists</a>(dominus_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="subsidialis.md#0x1_subsidialis_assert_solaris_exists">assert_solaris_exists</a>(dominus_address: <b>address</b>) {
	<b>assert</b>!(
	    <a href="solaris.md#0x1_solaris_exists_arxcoin">solaris::exists_arxcoin</a>(dominus_address) || <a href="solaris.md#0x1_solaris_exists_lp">solaris::exists_lp</a>(dominus_address),
	    <a href="../../std/doc/error.md#0x1_error_invalid_argument">error::invalid_argument</a>(<a href="subsidialis.md#0x1_subsidialis_ESOLARIS_DOES_NOT_EXIST">ESOLARIS_DOES_NOT_EXIST</a>)
	);
}
</code></pre>



</details>


[move-book]: https://move-language.github.io/move/introduction.html
