module arx::solaris {
    use arx::coin::{Self, Coin, MintCapability, BurnCapability};
    use arx::lux_coin::LuxCoin;
    use arx::nox_coin::NoxCoin;
    use arx::forma;
    use arx::system_addresses;

    use std::uq64x64;
    use std::math64;
    use std::signer;
    use std::error;

    friend arx::genesis;
    friend arx::subsidialis;

    struct Solaris<phantom CoinType> has key {
	/// Address of the owner of the solaris.
	owner_address: address,
	/// Active lux.
	active_lux: Coin<LuxCoin>,
	/// Lux pending activation. Occurs every epoch.
	pending_active_lux: Coin<LuxCoin>,
	/// Active nox.
	active_nox: Coin<NoxCoin>,
	/// Nox pending activation. Occurs every epoch where ARX > 1.
	pending_active_nox: Coin<NoxCoin>,
	/// Locked forma coins.
	locked_forma: Coin<CoinType>,
	/// Forma coins pending unlock.
	pending_unlocked_forma: Coin<CoinType>,
	/// Unlocked forma coins.
	unlocked_forma: Coin<CoinType>,
	/// The time remaining until the forma coins are withdrawable.
	time_remaining: u64,
    }

    /// Set during genesis and stored in the @core_resource account.
    /// Allows this module to mint and burn seignorage tokens.
    struct SeignorageCapability has key {
	lux_mint_cap: MintCapability<LuxCoin>,
	lux_burn_cap: BurnCapability<LuxCoin>,
	nox_mint_cap: MintCapability<NoxCoin>,
	nox_burn_cap: BurnCapability<NoxCoin>,
    }

    /// A solaris for a specified coin type was not found at the supplied address.
    const ESOLARIS_NOT_FOUND: u64 = 1;
    /// A solaris for a specified coin type already exists at the supplied address.
    const EEXISTING_SOLARIS: u64 = 2;

    /// Allows a module which creates solarii to 
    public(friend) fun store_seignorage_caps(
	arx: &signer,
	lux_mint_cap: MintCapability<LuxCoin>,
	lux_burn_cap: BurnCapability<LuxCoin>,
	nox_mint_cap: MintCapability<NoxCoin>,
	nox_burn_cap: BurnCapability<NoxCoin>,
    ) {
	system_addresses::assert_arx(arx);
	move_to(arx, SeignorageCapability {
	    lux_mint_cap, lux_burn_cap, nox_mint_cap, nox_burn_cap,
	});
    }

    /// Initialises a new solaris assigned to the provided owner.
    public entry fun initialize_owner<CoinType>(owner: &signer) {
	// Ensure a forma exists for this solaris.
	forma::assert_exists<CoinType>();
	// Ensure a solaris does not already exist for this owner.
	let owner_address = signer::address_of(owner);
	assert!(!exists<Solaris<CoinType>>(owner_address), error::already_exists(EEXISTING_SOLARIS));
	// Initialise a new solaris and move to owner.
	move_to(owner, Solaris {
	    owner_address,
	    active_lux: coin::zero<LuxCoin>(),
	    pending_active_lux: coin::zero<LuxCoin>(),
	    active_nox: coin::zero<NoxCoin>(),
	    pending_active_nox: coin::zero<NoxCoin>(),
	    locked_forma: coin::zero<CoinType>(),
	    pending_unlocked_forma: coin::zero<CoinType>(),
	    unlocked_forma: coin::zero<CoinType>(),
	    time_remaining: 0,
	});
    }

    /// Add forma coins to an existing solaris. External.
    public entry fun add_coins<CoinType>(owner: &signer, amount: u64)
	acquires SeignorageCapability, Solaris
    {
	let solaris_address = signer::address_of(owner);
	assert_exists<CoinType>(solaris_address);

	// Withdraw the specified amount of forma coins from the owners wallet.
	let coins = coin::withdraw<CoinType>(owner, amount);

	// Check that the coin value is != 0.
	let amount = coin::value(&coins);
	if (amount == 0) {
	    // Otherwise burn the 0 coins.
	    coin::destroy_zero(coins);
	    return
	};

	// Store the added coins into the solaris.
	let solaris = borrow_global_mut<Solaris<CoinType>>(solaris_address);
	coin::merge<CoinType>(&mut solaris.locked_forma, coins);

	// Mint the base seignorage reward for locking forma coins.
	mint_base_seignorage<CoinType>(solaris, amount);
    }

    /// Remove forma coins from an existing solaris. External.
    public entry fun remove_coins<CoinType>(owner: &signer, amount: u64)
	acquires SeignorageCapability, Solaris
    {
	// Short-circuit if amount to remove is 0 so that no events are emitted.
	if (amount == 0) {
	    return
	};
	
	// Fetch the solaris assigned to the current owner.
	let solaris_address = signer::address_of(owner);
	assert_exists<CoinType>(solaris_address);
	let solaris = borrow_global_mut<Solaris<CoinType>>(solaris_address);
	
	// Cap the amount to unlock by the maximum locked forma coins.
 	let locked_amount = coin::value(&solaris.locked_forma);
 	let remove_amount = math64::min(amount, locked_amount);
	// Return if the amount is 0.
 	if (amount == 0) {
 	    return
 	};
	// Move locked removed coins to pending unlocked. When the lockup cycle expires they will be
	// moved to unlocked and become withdrawable.
 	let removed_coins = coin::extract(&mut solaris.locked_forma, remove_amount);
 	coin::merge<CoinType>(&mut solaris.pending_unlocked_forma, removed_coins);

	// Compute (locked_amount / remove_amount) in order to calculate how much seignorage should be
	// burned for unlocking.
 	let seignorage_burn_fraction = uq64x64::decode(uq64x64::fraction(locked_amount, remove_amount));

 	// Burn a (active_nox_amount / seignorage_burn_fraction) of nox.
 	let nox_burn_cap = &borrow_global<SeignorageCapability>(@arx).nox_burn_cap;
 	let nox_amount = coin::value(&solaris.active_nox);
 	let nox_burn_amount = uq64x64::decode(uq64x64::fraction(nox_amount, seignorage_burn_fraction));
 	let nox_coins = coin::extract(&mut solaris.active_nox, nox_burn_amount);
 	coin::burn(nox_coins, nox_burn_cap);

 	// Burn a (active_lux_amount / seignorage_burn_fraction) of lux.
 	let lux_burn_cap = &borrow_global<SeignorageCapability>(@arx).lux_burn_cap;
 	let lux_amount = coin::value(&solaris.active_lux);
 	let lux_burn_amount = uq64x64::decode(uq64x64::fraction(lux_amount, seignorage_burn_fraction));
 	let lux_coins = coin::extract(&mut solaris.active_lux, lux_burn_amount);
 	coin::burn(lux_coins, lux_burn_cap);
    }

    /// Withdraw unlocked coins from an existing solaris. External.
    public entry fun withdraw_coins<CoinType>(owner: &signer, amount: u64)
	acquires Solaris
    {
	// Check that the amount to withdraw != 0, otherwise return.
	if (amount == 0) {
	    return
	};

	// Fetch the solaris assigned to the current owner.
	let solaris_address = signer::address_of(owner);
	assert_exists<CoinType>(solaris_address);
	let solaris = borrow_global_mut<Solaris<CoinType>>(solaris_address);

	// Compute the amount to withdraw capped by the unlocked amount.
	let unlocked_amount = coin::value(&solaris.unlocked_forma);
	let withdraw_amount = math64::min(amount, unlocked_amount);
	// Check that the withdrawn amount is non-zero, otherwise return.
	if (withdraw_amount == 0) {
	    return
	};

	// Move unlocked coins to owner.
	let withdrawn_coins = coin::extract(&mut solaris.unlocked_forma, withdraw_amount);
	coin::deposit<CoinType>(signer::address_of(owner), withdrawn_coins);
    }

    /// Reactivate forma coins pending unlock.
    public entry fun reactivate_coins<CoinType>(owner: &signer, amount: u64)
	acquires SeignorageCapability, Solaris
    {
	// Check that the amount to reactivate != 0, otherwise return.
	if (amount == 0) {
	    return
	};

	// Fetch the solaris assigned to the current owner.
	let solaris_address = signer::address_of(owner);
	assert_exists<CoinType>(solaris_address);
	let solaris = borrow_global_mut<Solaris<CoinType>>(solaris_address);

	// Compute the amount to reactivate capped by the pending unlocked amount.
	let pending_unlocked_amount = coin::value(&solaris.pending_unlocked_forma);
	let reactivate_amount = math64::min(amount, pending_unlocked_amount);
	// Check that the reactivate amount is non-zero, otherwise return.
	if (reactivate_amount == 0) {
	    return
	};

	// Move pending unlocked to active.
	let reactivated_coins = coin::extract(&mut solaris.pending_unlocked_forma, reactivate_amount);
	coin::merge<CoinType>(&mut solaris.locked_forma, reactivated_coins);

	// Re-assign seignorage to reactivated coins.
	mint_base_seignorage<CoinType>(solaris, reactivate_amount);
    }

    /// Allocate subsidialis based seignorage rewards. Only called from the subsidialis.
    public(friend) fun on_subsidialis_update<CoinType>(solaris_address: address)
	acquires Solaris, SeignorageCapability
    {
	// Fetch the solaris assigned to the current owner.
	assert_exists<CoinType>(solaris_address);
	let solaris = borrow_global_mut<Solaris<CoinType>>(solaris_address);

	// Pending active nox is moved to active (generated by the moneta)
	let pending_nox_amount = coin::value(&solaris.pending_active_nox);
	let pending_nox = coin::extract(&mut solaris.pending_active_nox, pending_nox_amount);
	coin::merge(&mut solaris.active_nox, pending_nox);

	// Pending active lux is moved to active (generated per epoch by held nox)
	let pending_lux_amount = coin::value(&solaris.pending_active_lux);
	let pending_lux = coin::extract(&mut solaris.pending_active_lux, pending_lux_amount);
	coin::merge(&mut solaris.active_lux, pending_lux);

	// Each active nox is used to generate 1/10000th of a pending_active lux
	let active_nox_value = coin::value(&solaris.active_nox);
	let pending_lux_reward = uq64x64::decode(uq64x64::fraction(active_nox_value, 10000));
	let lux_mint_cap = &borrow_global<SeignorageCapability>(@arx).lux_mint_cap;
	let lux_reward = coin::mint(pending_lux_reward, lux_mint_cap);
	coin::merge(&mut solaris.pending_active_lux, lux_reward);
    }

    /// Moves pending unlocked forma coins to unlocked. Only called from the subsidialis.
    public(friend) fun on_subsidialis_deactivate<CoinType>(solaris_address: address)
	acquires Solaris
    {
	// Fetch the solaris assigned to the current owner.
	assert_exists<CoinType>(solaris_address);
	let solaris = borrow_global_mut<Solaris<CoinType>>(solaris_address);

	// Pending unlocked forma coins are moved to unlocked
	let amount = coin::value(&solaris.pending_unlocked_forma);
	let pending_unlocked_forma = coin::extract(&mut solaris.pending_unlocked_forma, amount);
	coin::merge(&mut solaris.unlocked_forma, pending_unlocked_forma);
    }

    /// Gets the active lux value of a solaris.
    public fun get_active_lux_value<CoinType>(solaris_address: address): u64
	acquires Solaris
    {
	assert_exists<CoinType>(solaris_address);
	let solaris = borrow_global<Solaris<CoinType>>(solaris_address);
	coin::value(&solaris.active_lux)
    }

    /// Mint the base seignorage reward for locking forma coins.
    fun mint_base_seignorage<CoinType>(solaris: &mut Solaris<CoinType>, amount: u64)
	acquires SeignorageCapability
    {
	// Mint amount * lux_incentive coins.
	let lux_incentive = forma::get_lux_incentive<CoinType>();
	let lux_mint_cap = &borrow_global<SeignorageCapability>(@arx).lux_mint_cap;
	let lux_coins = coin::mint(amount * lux_incentive, lux_mint_cap);
	// Store the lux coins in the active lux.
	coin::merge(&mut solaris.active_lux, lux_coins);

	// Mint amount * nox_incentive coins.
	let nox_incentive = forma::get_nox_incentive<CoinType>();
	let nox_mint_cap = &borrow_global<SeignorageCapability>(@arx).nox_mint_cap;
	let nox_coins = coin::mint(amount * nox_incentive, nox_mint_cap);
	// Store the nox coins in the active nox.
	coin::merge(&mut solaris.active_nox, nox_coins);
    }

    /// Ensures a solaris exists for the supplied coin type at address.
    public fun assert_exists<CoinType>(address: address) {
	assert!(exists<Solaris<CoinType>>(address), error::not_found(ESOLARIS_NOT_FOUND));
    }
}
