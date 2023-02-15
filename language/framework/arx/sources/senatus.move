module arx::senatus {
    use arx::archon::{Self, Archon};
    use arx::solaris;
    use arx::system_addresses;

    use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::vector;
    
    struct Senatus has key {
	consensus_scheme: u8,
	active: vector<Archon>,
	pending_inactive: vector<Archon>,
	pending_active: vector<Archon>,
	total_lux_power: u128,
	total_joining_power: u128,
    }

    struct IndividualArchonPerformance has store, drop {
	successful_proposals: u64,
	failed_proposals: u64,
    }

    struct ArchonPerformance has key {
	archons: vector<IndividualArchonPerformance>,
    }

    /// Attempted to use a non existent solaris position.
    const ESOLARIS_DOES_NOT_EXIST: u64 = 1;

    /// Archon status enum. We can switch to proper enum later once Move supports it.
    const ARCHON_STATUS_PENDING_ACTIVE: u64 = 1;
    const ARCHON_STATUS_ACTIVE: u64 = 2;
    const ARCHON_STATUS_PENDING_INACTIVE: u64 = 3;
    const ARCHON_STATUS_INACTIVE: u64 = 4;

    /// Initialises the senatus, tracking archon performance. Called from genesis.
    public(friend) fun initialize(arx: &signer) {
	system_addresses::assert_arx(arx);

	move_to(arx, Senatus {
	    consensus_scheme: 0,
	    active: vector::empty(),
	    pending_active: vector::empty(),
	    pending_inactive: vector::empty(),
	    total_lux_power: 0,
	    total_joining_power: 0,
	});
	move_to(arx, ArchonPerformance {
	    archons: vector::empty(),
	});
    }

    /// Adds coins to an archons solaris.
    public entry fun add_coins<CoinType>(owner: &signer, amount: u64)
	acquires Senatus
    {
	let archon_address = signer::address_of(owner);
	solaris::assert_exists<CoinType>(archon_address);

	// Add coins and add pending_active seignorage if the archon is currently active in order to
	// make the seignorage count in the next epoch. If the archon is not yet active then the
	// seignorage can be immediately added to active, since they will activate in the next epoch.
	if (is_active_archon(archon_address)) {
	    solaris::add_pending_coins<CoinType>(owner, amount);
	} else {
	    solaris::add_active_coins<CoinType>(owner, amount);
	};

        // Only track and validate lux power increases for active and pending_active archons.
        // pending_inactive archons will be removed from the senatus in the next epoch.
        // Inactive archons total stake will be tracked when they join the senatus.
        let senatus = borrow_global_mut<Senatus>(@arx);
        // Search directly rather using get_archon_state to save on unnecessary loops.
        if (option::is_some(&find_archon(&senatus.active, archon_address)) ||
            option::is_some(&find_archon(&senatus.pending_active, archon_address))) {
            increase_joining_power(amount);
        };
	// TODO: Check for minimum / maximum power
    }

    fun increase_joining_power(amount: u64) acquires Senatus {
	let senatus = borrow_global_mut<Senatus>(@arx);
	senatus.total_joining_power = senatus.total_joining_power + (amount as u128);
	// TODO: Check for minimum / maximum power
    }

    /// Returns true is the specified archon is still participating in consensus as a validator.
    /// This includes archons which have requested to leave but are pending inactive.
    public fun is_active_archon(archon_address: address): bool acquires Senatus {
	assert_solaris_exists(archon_address);
	let archon_state = get_archon_state(archon_address);
	archon_state == ARCHON_STATUS_ACTIVE || archon_state == ARCHON_STATUS_PENDING_INACTIVE
    }

    /// Returns the archons current state in terms of consensus.
    fun get_archon_state(archon_address: address): u64 acquires Senatus {
        let senatus = borrow_global<Senatus>(@arx);
        if (option::is_some(&find_archon(&senatus.pending_active, archon_address))) {
            ARCHON_STATUS_PENDING_ACTIVE
        } else if (option::is_some(&find_archon(&senatus.active, archon_address))) {
            ARCHON_STATUS_ACTIVE
        } else if (option::is_some(&find_archon(&senatus.pending_inactive, archon_address))) {
            ARCHON_STATUS_PENDING_INACTIVE
        } else {
            ARCHON_STATUS_INACTIVE
        }
    }

    /// Finds an archon registered in the senatus by address.
    fun find_archon(v: &vector<Archon>, addr: address): Option<u64> {
        let i = 0;
        let len = vector::length(v);
        while ({
            spec {
                invariant !(exists j in 0..i: archon::get_owner_address(v[j]) == addr);
            };
            i < len
        }) {
            if (archon::get_owner_address(vector::borrow(v, i)) == addr) {
                return option::some(i)
            };
            i = i + 1;
        };
        option::none()
    }

    /// Ensures a solaris exists of either ArxCoin or LP<ArxCoin, XUSDCoin, Stable> at the supplied
    /// address.
    fun assert_solaris_exists(archon_address: address) {
	assert!(
	    solaris::exists_arxcoin(archon_address) || solaris::exists_lp(archon_address),
	    error::invalid_argument(ESOLARIS_DOES_NOT_EXIST)
	);
    }
}
