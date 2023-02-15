module arx::subsidialis {
    use arx::arx_coin::ArxCoin;
    use arx::account;
    use arx::solaris;
    use arx::system_addresses;

    use std::coin::{Self, Coin};
    use std::error;
    use std::event;
    use std::option::{Self, Option};
    use std::signer;
    use std::uq64x64;
    use std::vector;

    friend arx::genesis;
    friend arx::moneta;
    friend arx::reconfiguration;

    /// The set of solaris managed by the @arx subsidialis.
    /// 1. join adds to the pending_active subsidialis queue.
    /// 2. leave moves active to the pending_inactive subsidialis queue.
    /// 3. on_new_epoch processes the two pending queues.
    struct Subsidialis has key {
	/// The active domini of the current epoch.
	active: vector<address>,
	/// Dominus leaving in the next epoch.
	pending_inactive: vector<address>,
	/// Dominus joining in the next epoch.
	pending_active: vector<address>,
	/// The total lux active in the subsidialis.
	total_active_power: u128,
	/// The total lux waiting to join.
	total_joining_power: u128,
    }

    /// Stores the event handles of the subsidialis.
    struct SubsidialisEvents has key {
	subsidialis_initialized_events: event::EventHandle<SubsidialisInitializedEvent>,
	subsidialis_join_events: event::EventHandle<SubsidialisJoinEvent>,
	subsidialis_leave_events: event::EventHandle<SubsidialisLeaveEvent>,
	subsidialis_reconfiguration_events: event::EventHandle<SubsidialisReconfigurationEvent>,
    }

    /// Triggers when the subsidialis has been initialized.
    struct SubsidialisInitializedEvent has drop, store {}

    /// Triggers when a solaris owner becomes a dominus by joining the subsidialis.
    struct SubsidialisJoinEvent has drop, store {
	solaris_address: address
    }

    /// Triggers when a subsidialis member revokes their membership.
    struct SubsidialisLeaveEvent has drop, store {
	solaris_address: address,
    }

    /// Triggers when a new epoch causes the subsidialis to reconfigure itself.
    struct SubsidialisReconfigurationEvent has drop, store {
	total_active_power: u128,
    }

    /// The subsidialis was not initialized.
    const ESUBSIDIALIS_NOT_FOUND: u64 = 1;
    /// Attempted to active an already active dominus.
    const EDOMINUS_ALREADY_ACTIVE: u64 = 2;
    /// Attempted to deactivate an already inactive dominus.
    const EDOMINUS_ALREADY_INACTIVE: u64 = 3;
    /// Attempted to use a non existent solaris position.
    const ESOLARIS_DOES_NOT_EXIST: u64 = 4;

    /// Dominus is waiting to join the set.
    const DOMINUS_STATUS_PENDING_ACTIVE: u64 = 1;
    /// Dominus is actively receiving rewards.
    const DOMINUS_STATUS_ACTIVE: u64 = 2;
    /// Dominus is waiting to withdraw forma coins.
    const DOMINUS_STATUS_PENDING_INACTIVE: u64 = 3;
    /// Dominus is not an active participant.
    const DOMINUS_STATUS_INACTIVE: u64 = 4;

    public(friend) fun initialize(arx: &signer) {
	system_addresses::assert_arx(arx);
	move_to(arx, Subsidialis {
	    active: vector::empty(),
	    pending_inactive: vector::empty(),
	    pending_active: vector::empty(),
	    total_active_power: 0,
	    total_joining_power: 0,
	});
	let subsidialis_events = SubsidialisEvents {
	    subsidialis_initialized_events: account::new_event_handle(arx),
	    subsidialis_join_events: account::new_event_handle(arx),
	    subsidialis_leave_events: account::new_event_handle(arx),
	    subsidialis_reconfiguration_events: account::new_event_handle(arx),
	};
	event::emit_event(
	    &mut subsidialis_events.subsidialis_initialized_events,
	    SubsidialisInitializedEvent {},
	);
	move_to(arx, subsidialis_events);
    }

    /// Join the subsidialis with a pre-existing solaris of designated coin type.
    /// It is necessary to join the subsidialis in order to receive seignorage rewards.
    public entry fun join<CoinType>(owner: &signer)
	acquires Subsidialis, SubsidialisEvents
    {
	let solaris_address = signer::address_of(owner);
	// Ensure a solaris exists at the supplied address.
	solaris::assert_exists<CoinType>(solaris_address);

	// TODO: Ensure the solaris is not in senatus.

	// Ensure the solaris is not already an active dominus.
	assert!(
	    get_dominus_state(solaris_address) == DOMINUS_STATUS_INACTIVE,
	    error::invalid_state(EDOMINUS_ALREADY_ACTIVE),
	);

	// Push the solaris address to the pending active set.
	let subsidialis = borrow_global_mut<Subsidialis>(@arx);
	vector::push_back(&mut subsidialis.pending_active, solaris_address);

	let subsidialis_events = borrow_global_mut<SubsidialisEvents>(@arx);
	event::emit_event(
	    &mut subsidialis_events.subsidialis_join_events,
	    SubsidialisJoinEvent {
		solaris_address,
	    },
	);
    }
    
    /// Leave the subsidialis with a pre-existing solaris of designated coin type.
    /// It is necessary to leave the subsidialis in order for removed forma coins to become unlocked.
    public entry fun leave<CoinType>(owner: &signer)
	acquires Subsidialis, SubsidialisEvents
    {
	let solaris_address = signer::address_of(owner);
	// Ensure a solaris exists at the supplied address.
	solaris::assert_exists<CoinType>(solaris_address);

	// Ensure the owner of this solaris is an active member.
	assert!(
	    get_dominus_state(solaris_address) == DOMINUS_STATUS_ACTIVE,
	    error::invalid_state(EDOMINUS_ALREADY_INACTIVE),
	);

	// Push the solaris address to the pending inactive set.
	let subsidialis = borrow_global_mut<Subsidialis>(@arx);
	vector::push_back(&mut subsidialis.pending_inactive, solaris_address);

	let subsidialis_events = borrow_global_mut<SubsidialisEvents>(@arx);
	event::emit_event(
	    &mut subsidialis_events.subsidialis_leave_events,
	    SubsidialisLeaveEvent {
		solaris_address,
	    },
	);
    }

    /// Triggers at reconfiguration. This function should not abort.
    public(friend) fun on_new_epoch<CoinType>()
	acquires Subsidialis, SubsidialisEvents
    {
	assert_exists();
	let subsidialis = borrow_global_mut<Subsidialis>(@arx);

	// Update seignorage rewards for each active member.
	let i = 0;
	let vlen = vector::length(&subsidialis.active);
	while (i < vlen) {
	    let solaris_address = *vector::borrow(&subsidialis.active, i);
	    solaris::on_subsidialis_update<CoinType>(solaris_address);
	    i = i + 1;
	};

	// Activate currently pending_active members.
        vector::append_nondestructive(&mut subsidialis.active, &mut subsidialis.pending_active);

	// Unlock pending_unlocked forma coins within the solarii.
	let subsidialis_lux_power = 0;
	let i = 0;
	let vlen = vector::length(&subsidialis.pending_inactive);
	while (i < vlen) {
	    let solaris_address = *vector::borrow(&subsidialis.pending_inactive, i);
	    solaris::on_subsidialis_deactivate<CoinType>(solaris_address);
	    // Subtract the active lux power of the solaris from the total active power.
	    let active_lux_value = solaris::get_active_lux_value<CoinType>(solaris_address);
	    subsidialis_lux_power = subsidialis_lux_power + active_lux_value;
	    i = i + 1;
	};
	// Set pending_inactive to () since they have been deactivated.
	subsidialis.pending_inactive = vector::empty();
	subsidialis.total_active_power =
	    subsidialis.total_active_power - (subsidialis_lux_power as u128);

	// Compute the total lux power and set joining power to 0.
	let subsidialis_lux_power = 0;
	let i = 0;
	let vlen = vector::length(&subsidialis.active);
	while (i < vlen) {
	    let solaris_address = *vector::borrow(&subsidialis.active, i);
	    let active_lux_value = solaris::get_active_lux_value<CoinType>(solaris_address);
	    subsidialis_lux_power = subsidialis_lux_power + active_lux_value;
	    // TODO: renew_timelock();
	    i = i + 1;
	};
	// IMPORTANT: The total lux power *must* be set to 0 prior to calling `on_new_epoch` with
	// different coin types.
	subsidialis.total_active_power =
	    subsidialis.total_active_power + (subsidialis_lux_power as u128);

	let subsidialis_events = borrow_global_mut<SubsidialisEvents>(@arx);
	event::emit_event(
	    &mut subsidialis_events.subsidialis_reconfiguration_events,
	    SubsidialisReconfigurationEvent {
		total_active_power: subsidialis.total_active_power,
	    },
	);
    }

    /// Distribute moneta mints to the solaris set.
    public(friend) fun distribute_mints<CoinType>(coins: Coin<ArxCoin>) acquires Subsidialis {
	assert_exists();
	let subsidialis = borrow_global<Subsidialis>(@arx);
	// FIXME: (downcasting) Update forma rewards for each active member.
	let total_power = (subsidialis.total_active_power as u64);
	let i = 0;
	let vlen = vector::length(&subsidialis.active);
	while (i < vlen) {
	    let solaris_address = *vector::borrow(&subsidialis.active, i);
	    // Compute the share which this active subsidialis is owed.
	    let active_lux_value = solaris::get_active_lux_value<CoinType>(solaris_address);
	    let active_lux_share = uq64x64::decode(uq64x64::fraction(active_lux_value, total_power));
	    let coin_share = active_lux_share * coin::value(&coins);
	    let coins = coin::extract(&mut coins, coin_share);
	    // Deposit the mints directly in the solaris (owners) account.
	    coin::deposit(solaris_address, coins);
	    i = i + 1;
	};
	// Should fail if the mints were not rewarded fully.
	coin::destroy_zero<ArxCoin>(coins);
    }

    /// Adds coins to a dominuses solaris.
    public entry fun add_coins<CoinType>(owner: &signer, amount: u64)
	acquires Subsidialis
    {
	let dominus_address = signer::address_of(owner);
	solaris::assert_exists<CoinType>(dominus_address);

	// Add coins and add pending_active seignorage if the dominus is currently active in order to
	// make the seignorage count in the next epoch. If the dominus is not yet active then the
	// seignorage can be immediately added to active, since they will activate in the next epoch.
	if (is_active_dominus(dominus_address)) {
	    solaris::add_pending_coins<CoinType>(owner, amount);
	} else {
	    solaris::add_active_coins<CoinType>(owner, amount);
	};

        // Only track and validate lux power increases for active and pending_active dominuss.
        // pending_inactive dominui will be removed from the subsidialis in the next epoch.
        // Inactive domini total stake will be tracked when they join the subsidialis.
        let subsidialis = borrow_global_mut<Subsidialis>(@arx);
        // Search directly rather using get_archon_state to save on unnecessary loops.
        if (option::is_some(&find_dominus(&subsidialis.active, dominus_address)) ||
            option::is_some(&find_dominus(&subsidialis.pending_active, dominus_address))) {
            increase_joining_power(amount);
        };
    }

    fun increase_joining_power(amount: u64) acquires Subsidialis {
	let subsidialis = borrow_global_mut<Subsidialis>(@arx);
	subsidialis.total_joining_power = subsidialis.total_joining_power + (amount as u128);
	// TODO: Check for minimum / maximum power
    }

    /// Returns true is the specified archon is still participating in the subsidialis.
    /// This includes domini which have requested to leave but are pending inactive.
    public fun is_active_dominus(dominus_address: address): bool acquires Subsidialis {
	assert_solaris_exists(dominus_address);
	let dominus_state = get_dominus_state(dominus_address);
	dominus_state == DOMINUS_STATUS_ACTIVE || dominus_state == DOMINUS_STATUS_PENDING_INACTIVE
    }

    /// Returns the state of an dominus.
    public fun get_dominus_state(lock_address: address): u64
	acquires Subsidialis
    {
	let subsidialis = borrow_global<Subsidialis>(@arx);
	if (option::is_some(&find_dominus(&subsidialis.pending_active, lock_address))) {
	    DOMINUS_STATUS_PENDING_ACTIVE
        } else if (option::is_some(&find_dominus(&subsidialis.active, lock_address))) {
	    DOMINUS_STATUS_ACTIVE
        } else if (option::is_some(&find_dominus(&subsidialis.pending_inactive, lock_address))) {
	    DOMINUS_STATUS_PENDING_INACTIVE
        } else {
	    DOMINUS_STATUS_INACTIVE
        }
    }

    /// Finds the current status of a designated dominus by lock address.
    fun find_dominus(v: &vector<address>, address: address): Option<u64> {
        let i = 0;
        let vlen = vector::length(v);
        while ({
            spec {
                invariant !(exists j in 0..i: v[j] == address);
            };
            i < vlen
        }) {
            if (*vector::borrow(v, i) == address) {
                return option::some(i)
            };
            i = i + 1;
        };
        option::none()
    }

    /// Get the total active lux power.
    public fun get_total_active_power<CoinType>(): u128
	acquires Subsidialis
    {
	let subsidialis = borrow_global<Subsidialis>(@arx);
	subsidialis.total_active_power
    }

    /// Ensures the subsidialis exists.
    public fun assert_exists() {
	assert!(exists<Subsidialis>(@arx), error::not_found(ESUBSIDIALIS_NOT_FOUND));
    }

    /// Ensures a solaris exists of either ArxCoin or LP<ArxCoin, XUSDCoin, Stable> at the supplied
    /// address.
    fun assert_solaris_exists(dominus_address: address) {
	assert!(
	    solaris::exists_arxcoin(dominus_address) || solaris::exists_lp(dominus_address),
	    error::invalid_argument(ESOLARIS_DOES_NOT_EXIST)
	);
    }
}
