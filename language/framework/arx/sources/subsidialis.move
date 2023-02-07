module arx::subsidialis {
    use arx::solaris;

    use std::option::{Self, Option};
    use std::vector;
    use std::signer;
    use std::error;

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

    /// The subsidialis was not initialized.
    const ESUBSIDIALIS_NOT_FOUND: u64 = 1;
    /// Attempted to active an already active dominus.
    const EDOMINUS_ALREADY_ACTIVE: u64 = 2;
    /// Attempted to deactivate an already inactive dominus.
    const EDOMINUS_ALREADY_INACTIVE: u64 = 3;

    /// Dominus is waiting to join the set.
    const DOMINUS_STATUS_PENDING_ACTIVE: u64 = 1;
    /// Dominus is actively receiving rewards.
    const DOMINUS_STATUS_ACTIVE: u64 = 2;
    /// Dominus is waiting to withdraw forma coins.
    const DOMINUS_STATUS_PENDING_INACTIVE: u64 = 3;
    /// Dominus is not an active participant.
    const DOMINUS_STATUS_INACTIVE: u64 = 4;

    /// Join the subsidialis with a pre-existing solaris of designated coin type.
    /// It is necessary to join the subsidialis in order to receive seignorage rewards.
    public entry fun join<CoinType>(owner: &signer)
	acquires Subsidialis
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
    }
    
    /// Leave the subsidialis with a pre-existing solaris of designated coin type.
    /// It is necessary to leave the subsidialis in order for removed forma coins to become unlocked.
    public entry fun leave<CoinType>(owner: &signer)
	acquires Subsidialis
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
    }

    /// Triggers at reconfiguration. This function should not abort.
    public(friend) fun on_new_epoch<CoinType>()
	acquires Subsidialis
    {
	assert_exists();
	let subsidialis = borrow_global_mut<Subsidialis>(@arx);

	// Update seignorage rewards for each active member.
	let i = 0;
	let len = vector::length(&subsidialis.active);
	while (i < len) {
	    let solaris_address = *vector::borrow(&subsidialis.active, i);
	    solaris::on_subsidialis_update<CoinType>(solaris_address);
	    i = i + 1;
	};

	// Activate currently pending_active members.
        vector::append_nondestructive(&mut subsidialis.active, &mut subsidialis.pending_active);

	// Unlock pending_unlocked forma coins within the solarii.
	let i = 0;
	let len = vector::length(&subsidialis.pending_inactive);
	while (i < len) {
	    let solaris_address = *vector::borrow(&subsidialis.pending_inactive, i);
	    solaris::on_subsidialis_deactivate<CoinType>(solaris_address);
	    i = i + 1;
	};
	// Set pending_inactive to () since they have been deactivated.
	subsidialis.pending_inactive = vector::empty();

	// Compute the total lux power and set joining power to 0.
	let subsidialis_lux_power = 0;
	let i = 0;
	let vlen = vector::length(&subsidialis.active);
	while (i < vlen) {
	    let solaris_address = *vector::borrow(&subsidialis.active, i);
	    let active_lux_value = solaris::get_active_lux_value<CoinType>(solaris_address);
	    subsidialis_lux_power = subsidialis_lux_power + active_lux_value;
	    // TODO: renew_timelock();
	};
	// IMPORTANT: The total lux power *must* be set to 0 prior to calling `on_new_epoch` with
	// different coin types.
	subsidialis.total_active_power = subsidialis.total_active_power + (subsidialis_lux_power as u128);
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
        let len = vector::length(v);
        while ({
            spec {
                invariant !(exists j in 0..i: v[j] == address);
            };
            i < len
        }) {
            if (*vector::borrow(v, i) == address) {
                return option::some(i)
            };
            i = i + 1;
        };
        option::none()
    }

    /// Ensures the subsidialis exists.
    public fun assert_exists() {
	assert!(exists<Subsidialis>(@arx), error::not_found(ESUBSIDIALIS_NOT_FOUND));
    }
}
