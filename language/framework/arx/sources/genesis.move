module arx::genesis {
    use std::error;
    use std::vector;
    use std::curves::Stable;

    use arx::account;
    use arx::aggregator_factory;
    use arx::arx_coin::{Self, ArxCoin};
    use arx::governance;
    use arx::block;
    use arx::chain_id;
    use arx::chain_status;
    use arx::coin;
    use arx::consensus_config;
    use arx::create_signer::create_signer;
    use arx::forma;
    use arx::gas_schedule;
    use arx::lp_coin::LP;
    use arx::lux_coin;
    use arx::moneta;
    use arx::nox_coin;
    use arx::reconfiguration;
    use arx::validator;
    use arx::validation_config;
    use arx::solaris;
    use arx::subsidialis;
    use arx::state_storage;
    use arx::storage_gas;
    use arx::timestamp;
    use arx::transaction_fee;
    use arx::transaction_validation;
    use arx::version;
    use arx::xusd_coin::{Self, XUSDCoin};

    const EDUPLICATE_ACCOUNT: u64 = 1;
    const EACCOUNT_DOES_NOT_EXIST: u64 = 2;

    struct AccountMap has drop {
        account_address: address,
        balance: u64,
    }

    struct DominusConfiguration has copy, drop {
	owner_address: address,
	allocation_amount: u64,
    }

    struct ValidatorConfiguration has copy, drop {
        owner_address: address,
        operator_address: address,
        vault_address: address,
        stake_amount: u64,
        consensus_pubkey: vector<u8>,
        proof_of_possession: vector<u8>,
        network_addresses: vector<u8>,
        full_node_network_addresses: vector<u8>,
    }

    struct ValidatorConfigurationWithCommission has copy, drop {
        validator_config: ValidatorConfiguration,
        commission_percentage: u64,
        join_during_genesis: bool,
    }

    /// Genesis step 1: Initialize ol framework account and core modules on chain.
    fun initialize(
        gas_schedule: vector<u8>,
        chain_id: u8,
        initial_version: u64,
        consensus_config: vector<u8>,
        epoch_interval_microsecs: u64,
	minimum_stake: u64,
	maximum_stake: u64,
        recurring_lockup_duration_secs: u64,
        allow_validator_set_change: bool,
        rewards_rate: u64,
        rewards_rate_denominator: u64,
        voting_power_increase_limit: u64,
    ) {
        // Initialize the arx account. This is the account where system resources and modules
	// will be deployed to. This will be entirely managed by on-chain governance and no entities have the key or privileges
        // to use this account.
        let (arx, arx_signer_cap) = account::create_reserved_account(@arx);
        // Initialize account configs on the arx framework account.
        account::initialize(&arx);

        transaction_validation::initialize(
            &arx,
            b"script_prologue",
            b"module_prologue",
            b"multi_agent_script_prologue",
            b"epilogue",
        );

        // Give the decentralized on-chain governance control over the core framework account.
        governance::store_signer_cap(&arx, @arx, arx_signer_cap);

        // Give governance control over the reserved addresses.
        let reserved_addresses = vector<address>[@0x2, @0x3, @0x4, @0x5, @0x6, @0x7, @0x8, @0x9, @0xa];
        while (!vector::is_empty(&reserved_addresses)) {
            let address = vector::pop_back<address>(&mut reserved_addresses);
            let (arx, reserved_signer_cap) = account::create_reserved_account(address);
            governance::store_signer_cap(&arx, address, reserved_signer_cap);
        };

        consensus_config::initialize(&arx, consensus_config);
        version::initialize(&arx, initial_version);
        validator::initialize(&arx);
        validation_config::initialize(
            &arx,
	    minimum_stake,
	    maximum_stake,
            recurring_lockup_duration_secs,
            allow_validator_set_change,
            rewards_rate,
            rewards_rate_denominator,
            voting_power_increase_limit,
        );
        storage_gas::initialize(&arx);
        gas_schedule::initialize(&arx, gas_schedule);

        // Ensure we can create aggregators for supply, but not enable it for common use just yet.
        aggregator_factory::initialize_aggregator_factory(&arx);
        coin::initialize_supply_config(&arx);

        chain_id::initialize(&arx, chain_id);
        reconfiguration::initialize(&arx);
        block::initialize(&arx, epoch_interval_microsecs);
        state_storage::initialize(&arx);
        timestamp::set_time_has_started(&arx);
    }

    // Genesis step 2: Initialize Arx coin.
    fun initialize_arx_coin(arx: &signer) {
        let (burn_cap, mint_cap) = arx_coin::initialize(arx);
        // Give the `validator` module MintCapability<ArxCoin> so it can mint rewards.
        validator::store_arx_coin_mint_cap(arx, mint_cap);
        // Give transaction_fee module BurnCapability<ArxCoin> so it can burn gas.
        transaction_fee::store_arx_coin_burn_cap(arx, burn_cap);
    }

    /// Only called for testnets and e2e tests.
    fun initialize_core_resources_and_arx_coin(
        arx: &signer,
        core_resources_auth_key: vector<u8>,
    ) {
	// Initialize coin capabilities.
        let (arx_burn_cap, arx_mint_cap) = arx_coin::initialize(arx);
	let (nox_burn_cap, nox_mint_cap) = nox_coin::initialize(arx);
	let (lux_burn_cap, lux_mint_cap) = lux_coin::initialize(arx);
	let (xusd_burn_cap, xusd_mint_cap) = xusd_coin::initialize(arx);
	// TODO: Remove validator mint capability.
        // Give `validator` module MintCapability<ArxCoin> so it can mint rewards.
        validator::store_arx_coin_mint_cap(arx, arx_mint_cap);
	// Give `moneta` module MintCapability<ArxCoin> so it can mint `ARX`.
	moneta::store_arx_coin_mint_cap(arx, arx_mint_cap, arx_burn_cap);
	// Give `moneta` module MintCapability<XUSD> so it can mint `XUSD` (testing only).
	moneta::store_xusd_coin_mint_cap(arx, xusd_mint_cap, xusd_burn_cap);
        // Give `transaction_fee` module BurnCapability<ArxCoin> so it can burn gas.
        transaction_fee::store_arx_coin_burn_cap(arx, arx_burn_cap);
	// Give `solaris` module seignorage capabilities.
	solaris::store_seignorage_caps(arx, lux_mint_cap, lux_burn_cap, nox_mint_cap, nox_burn_cap);

        let core_resources = account::create_account(@core_resources);
        account::rotate_authentication_key_internal(&core_resources, core_resources_auth_key);
        arx_coin::configure_accounts_for_test(arx, &core_resources, arx_mint_cap);
	xusd_coin::configure_accounts_for_test(arx, &core_resources, xusd_mint_cap);

	// Initialises the required liquidity pool and mints some initial liquidity.
	moneta::initialize_for_testing(arx);
	// Registers the required forma types for the creation of solaris.
	forma::initialize(arx);
	// Initialises an empty subsidialis set so that domini can be added.
	subsidialis::initialize(arx);
    }

    fun create_accounts(arx: &signer, accounts: vector<AccountMap>) {
        let i = 0;
        let num_accounts = vector::length(&accounts);
        let unique_accounts = vector::empty();

        while (i < num_accounts) {
            let account_map = vector::borrow(&accounts, i);
            assert!(
                !vector::contains(&unique_accounts, &account_map.account_address),
                error::already_exists(EDUPLICATE_ACCOUNT),
            );
            vector::push_back(&mut unique_accounts, account_map.account_address);

            create_account(
                arx,
                account_map.account_address,
                account_map.balance,
            );

            i = i + 1;
        };
    }

    /// This creates an funds an account if it doesn't exist.
    /// If it exists, it just returns the signer.
    fun create_account(arx: &signer, account_address: address, balance: u64): signer {
        if (account::exists_at(account_address)) {
            create_signer(account_address)
        } else {
            let account = account::create_account(account_address);
            coin::register<ArxCoin>(&account);
            arx_coin::mint(arx, account_address, balance);
            account
        }
    }

    fun create_initialize_validators_with_commission(
        arx: &signer,
        validators: vector<ValidatorConfigurationWithCommission>,
    ) {
        let i = 0;
        let num_validators = vector::length(&validators);
        while (i < num_validators) {
            let validator = vector::borrow(&validators, i);
            create_initialize_validator(arx, validator);
            i = i + 1;
        };

        // Destroy arxs ability to mint coins now that we're done with setting up the initial
        // validators.
        arx_coin::destroy_mint_cap(arx);

	// Transition to the next validation epoch
        validator::on_new_epoch();
    }

    /// Sets up the initial members of the subsidialis. 
    fun create_initialize_domini(arx: &signer, domini: vector<DominusConfiguration>) {
	let i = 0;
	let num_domini = vector::length(&domini);
	while (i < num_domini) {
	    let dominus = vector::borrow(&domini, i);
	    create_initialize_dominus(arx, dominus);
	    i = i + 1;
	};

	// Transition to the next moneta epoch
	moneta::on_new_epoch();
	// Transition to the next `ArxCoin` subsidialis epoch.
	subsidialis::on_new_epoch<ArxCoin>();
	// Transition to the next `LP<ArxCoin, XUSD>` subsidialis epoch.
	subsidialis::on_new_epoch<LP<ArxCoin, XUSDCoin, Stable>>();
	// TODO: Transition to the next senatus epoch.
    }

    fun create_initialize_dominus(
	arx: &signer,
	dominus: &DominusConfiguration,
    ) {
	let owner = &create_account(arx, dominus.owner_address, dominus.allocation_amount);
	// Initialise the solaris allocation. 
	solaris::initialize_allocation<ArxCoin>(owner, dominus.allocation_amount);
	// Join the subsidialis.
	subsidialis::join<ArxCoin>(owner);
    }

    /// Sets up the initial validator set for the network.
    /// The validator "owner" accounts, and their authentication
    /// Addresses (and keys) are encoded in the `owners`
    /// Each validator signs consensus messages with the private key corresponding to the Ed25519
    /// public key in `consensus_pubkeys`.
    /// Finally, each validator must specify the network address
    /// (see types/src/network_address/mod.rs) for itself and its full nodes.
    ///
    /// Network address fields are a vector per account, where each entry is a vector of addresses
    /// encoded in a single BCS byte array.
    fun create_initialize_validators(arx: &signer, validators: vector<ValidatorConfiguration>) {
        let i = 0;
        let num_validators = vector::length(&validators);

        let validators_with_commission = vector::empty();

        while (i < num_validators) {
            let validator_with_commission = ValidatorConfigurationWithCommission {
                validator_config: vector::pop_back(&mut validators),
                commission_percentage: 0,
                join_during_genesis: true,
            };
            vector::push_back(&mut validators_with_commission, validator_with_commission);

            i = i + 1;
        };

        create_initialize_validators_with_commission(arx, validators_with_commission);
    }

    fun create_initialize_validator(
        arx: &signer,
        commission_config: &ValidatorConfigurationWithCommission,
    ) {
        let validator = &commission_config.validator_config;

        let owner = &create_account(arx, validator.owner_address, validator.stake_amount);
        create_account(arx, validator.operator_address, 0);
        create_account(arx, validator.vault_address, 0);

        // Initialize the stake lock and join the validator set.
        validator::initialize_stake_owner(
            owner,
            validator.stake_amount,
            validator.operator_address,
            validator.vault_address,
        );
        let lock_address = validator.owner_address;

        if (commission_config.join_during_genesis) {
            initialize_validator(lock_address, validator);
        };
    }

    fun initialize_validator(lock_address: address, validator: &ValidatorConfiguration) {
        let operator = &create_signer(validator.operator_address);

        validator::rotate_consensus_key(
            operator,
            lock_address,
            validator.consensus_pubkey,
            validator.proof_of_possession,
        );
        validator::update_network_info(
            operator,
            lock_address,
            validator.network_addresses,
            validator.full_node_network_addresses,
        );
        validator::join_validator_set_internal(operator, lock_address);
    }

    /// The last step of genesis.
    fun set_genesis_end(arx: &signer) {
        chain_status::set_genesis_end(arx);
    }

    #[verify_only]
    use std::features;

    #[verify_only]
    fun initialize_for_verification(
        gas_schedule: vector<u8>,
        chain_id: u8,
        initial_version: u64,
        consensus_config: vector<u8>,
        epoch_interval_microsecs: u64,
        minimum_stake: u64,
        maximum_stake: u64,
        recurring_lockup_duration_secs: u64,
        allow_validator_set_change: bool,
        rewards_rate: u64,
        rewards_rate_denominator: u64,
        voting_power_increase_limit: u64,
        arx: &signer,
        min_voting_threshold: u128,
        required_proposer_stake: u64,
        voting_duration_secs: u64,
        accounts: vector<AccountMap>,
        validators: vector<ValidatorConfigurationWithCommission>
    ) {
        initialize(
            gas_schedule,
            chain_id,
            initial_version,
            consensus_config,
            epoch_interval_microsecs,
            minimum_stake,
            maximum_stake,
            recurring_lockup_duration_secs,
            allow_validator_set_change,
            rewards_rate,
            rewards_rate_denominator,
            voting_power_increase_limit
        );
        features::change_feature_flags(arx, vector[1, 2], vector[]);
        initialize_arx_coin(arx);
        governance::initialize_for_verification(
            arx,
            min_voting_threshold,
            required_proposer_stake,
            voting_duration_secs
        );
        create_accounts(arx, accounts);
        create_initialize_validators_with_commission(arx, validators);
        set_genesis_end(arx);
    }

    #[test_only]
    public fun setup() {
        initialize(
            x"000000000000000000", // empty gas schedule
            4u8, // TESTING chain ID
            0,
            x"12",
            1,
            0,
            1,
            1,
            true,
            1,
            1,
            30,
        )
    }

    #[test]
    fun test_setup() {
        setup();
        assert!(account::exists_at(@arx), 1);
        assert!(account::exists_at(@0x2), 1);
        assert!(account::exists_at(@0x3), 1);
        assert!(account::exists_at(@0x4), 1);
        assert!(account::exists_at(@0x5), 1);
        assert!(account::exists_at(@0x6), 1);
        assert!(account::exists_at(@0x7), 1);
        assert!(account::exists_at(@0x8), 1);
        assert!(account::exists_at(@0x9), 1);
        assert!(account::exists_at(@0xa), 1);
    }

    #[test(arx = @0x1)]
    fun test_create_account(arx: &signer) {
        setup();
        initialize_arx_coin(arx);

        let addr = @0x121341; // 01 -> 0a are taken
        let test_signer_before = create_account(arx, addr, 15);
        let test_signer_after = create_account(arx, addr, 500);
        assert!(test_signer_before == test_signer_after, 0);
        assert!(coin::balance<ArxCoin>(addr) == 15, 1);
    }

    #[test(arx = @0x1)]
    fun test_create_accounts(arx: &signer) {
        setup();
        initialize_arx_coin(arx);

        // 01 -> 0a are taken
        let addr0 = @0x121341;
        let addr1 = @0x121345;

        let accounts = vector[
            AccountMap {
                account_address: addr0,
                balance: 12345,
            },
            AccountMap {
                account_address: addr1,
                balance: 67890,
            },
        ];

        create_accounts(arx, accounts);
        assert!(coin::balance<ArxCoin>(addr0) == 12345, 0);
        assert!(coin::balance<ArxCoin>(addr1) == 67890, 1);

        create_account(arx, addr0, 23456);
        assert!(coin::balance<ArxCoin>(addr0) == 12345, 2);
    }
}
