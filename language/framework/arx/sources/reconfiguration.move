/// Publishes configuration information for validators, and issues reconfiguration events
/// to synchronize configuration changes for the validators.
module arx::reconfiguration {
    use std::curves::Stable;
    use std::error;
    use std::features;
    use std::signer;

    use arx::account;
    use arx::arx_coin::ArxCoin;
    use arx::lp_coin::LP;
    use arx::xusd_coin::XUSDCoin;
    use arx::chain_status;
    use arx::event;
    use arx::liquidity_pool;
    use arx::moneta;
    use arx::system_addresses;
    use arx::storage_gas;
    use arx::subsidialis;
    use arx::timestamp;
    use arx::transaction_fee;
    use arx::validator;

    friend arx::governance;
    friend arx::block;
    friend arx::consensus_config;
    friend arx::gas_schedule;
    friend arx::genesis;
    friend arx::version;

    /// Event that signals consensus to start a new epoch with new configuration information. This is
    /// also called a "reconfiguration event".
    struct NewEpochEvent has drop, store {
        epoch: u64,
    }

    /// Holds information about state of reconfiguration
    struct Configuration has key {
        /// Epoch number
        epoch: u64,
        /// Time of last reconfiguration. Only changes on `NewEpochEvent`s.
        last_reconfiguration_time: u64,
        /// Event handle for reconfiguration events
        events: event::EventHandle<NewEpochEvent>,
    }

    /// Reconfiguration will be disabled if this resource is published under the
    /// arx system address
    struct DisableReconfiguration has key {}

    /// The `Configuration` resource is in an invalid state
    const ECONFIGURATION: u64 = 1;
    /// A `Reconfiguration` resource is in an invalid state
    const ECONFIG: u64 = 2;
    /// A `ModifyConfigCapability` is in a different state than was expected
    const EMODIFY_CAPABILITY: u64 = 3;
    /// An invalid block time was encountered.
    const EINVALID_BLOCK_TIME: u64 = 4;
    /// An invalid block time was encountered.
    const EINVALID_GUID_FOR_EVENT: u64 = 5;

    /// Only called during genesis.
    /// Publishes `Configuration` resource. Can only be invoked by the arxaccount, and only a
    /// single time in Genesis.
    public(friend) fun initialize(arx: &signer) {
        system_addresses::assert_arx(arx);

        // assert it matches `new_epoch_event_key()`, otherwise the event can't be recognized
        assert!(
	    account::get_guid_next_creation_num(signer::address_of(arx)) == 2,
	    error::invalid_state(EINVALID_GUID_FOR_EVENT),
	);
        move_to<Configuration>(
            arx,
            Configuration {
                epoch: 0,
                last_reconfiguration_time: 0,
                events: account::new_event_handle<NewEpochEvent>(arx),
            }
        );
    }

    /// Private function to temporarily halt reconfiguration.
    /// This function should only be used for offline WriteSet generation purpose and should never be
    /// invoked on chain.
    fun disable_reconfiguration(arx: &signer) {
        system_addresses::assert_arx(arx);
        assert!(reconfiguration_enabled(), error::invalid_state(ECONFIGURATION));
        move_to(arx, DisableReconfiguration {})
    }

    /// Private function to resume reconfiguration.
    /// This function should only be used for offline WriteSet generation purpose and should never be
    /// invoked on chain.
    fun enable_reconfiguration(arx: &signer) acquires DisableReconfiguration {
        system_addresses::assert_arx(arx);

        assert!(!reconfiguration_enabled(), error::invalid_state(ECONFIGURATION));
        DisableReconfiguration {} = move_from<DisableReconfiguration>(signer::address_of(arx));
    }

    fun reconfiguration_enabled(): bool {
        !exists<DisableReconfiguration>(@arx)
    }

    /// Signal validators to start using new configuration. Must be called from friend config modules.
    public(friend) fun reconfigure() acquires Configuration {
        // Do not do anything if genesis has not finished.
        if (chain_status::is_genesis() || timestamp::now_microseconds() == 0 || !reconfiguration_enabled()) {
            return
        };

        let config_ref = borrow_global_mut<Configuration>(@arx);
        let current_time = timestamp::now_microseconds();

        // Do not do anything if a reconfiguration event is already emitted within this transaction.
        //
        // This is OK because:
        // - The time changes in every non-empty block
        // - A block automatically ends after a transaction that emits a reconfiguration event, which is
	// guaranteed by VM spec that all transactions comming after a reconfiguration transaction will
	// be returned as Retry status.
        // - Each transaction must emit at most one reconfiguration event
        //
        // Thus, this check ensures that a transaction that does multiple "reconfiguration required"
	// actions emits only one reconfiguration event.
        //
        if (current_time == config_ref.last_reconfiguration_time) {
            return
        };

        // Reconfiguration "forces the block" to end, as mentioned above. Therefore, we must process
	// the collected fees explicitly so that staking can distribute them.
        //
        // This also handles the case when a validator is removed due to the governance proposal. In
	// particular, removing the validator causes a reconfiguration. We explicitly process fees,
	// i.e. we drain aggregatable coin and populate the fees table, prior to calling
	// `on_new_epoch()`. That call, in turn, distributes transaction fees for all active and
	// pending_inactive validators, which include any validator that is to be removed.
        if (features::collect_and_distribute_gas_fees()) {
            // All transactions after reconfiguration are Retry. Therefore, when the next
            // block starts and tries to assign/burn collected fees it will be just 0 and
            // nothing will be assigned.
            transaction_fee::process_collected_fees();
        };

        // Compute the new validator set and distribute rewards (and maybe) transaction fees.
        validator::on_new_epoch();

	// Compute the new minting rewards and distribute to the subsidialis, senatus and the danistae.
	moneta::on_new_epoch();
	// Compute the seignorage rewards of the subsidialis.
	subsidialis::on_new_epoch<ArxCoin>();
	subsidialis::on_new_epoch<LP<ArxCoin, XUSDCoin, Stable>>();
	// TODO: Compute the seignorage rewards of the senatus.

        storage_gas::on_reconfig();

        assert!(
	    current_time > config_ref.last_reconfiguration_time,
	    error::invalid_state(EINVALID_BLOCK_TIME)
	);
        config_ref.last_reconfiguration_time = current_time;
        spec {
            assume config_ref.epoch + 1 <= MAX_U64;
        };
        config_ref.epoch = config_ref.epoch + 1;

	// Update liquidity pool last epoch timestamp
	liquidity_pool::set_reconfiguration_timestamp<ArxCoin, XUSDCoin, Stable>(current_time);

        event::emit_event<NewEpochEvent>(
            &mut config_ref.events,
            NewEpochEvent {
                epoch: config_ref.epoch,
            },
        );
    }

    public fun last_reconfiguration_time(): u64 acquires Configuration {
        borrow_global<Configuration>(@arx).last_reconfiguration_time
    }

    public fun current_epoch(): u64 acquires Configuration {
        borrow_global<Configuration>(@arx).epoch
    }

    /// Emit a `NewEpochEvent` event. This function will be invoked by genesis directly to generate the
    /// very first reconfiguration event.
    fun emit_genesis_reconfiguration_event() acquires Configuration {
        let config_ref = borrow_global_mut<Configuration>(@arx);
        assert!(config_ref.epoch == 0 && config_ref.last_reconfiguration_time == 0, error::invalid_state(ECONFIGURATION));
        config_ref.epoch = 1;

        event::emit_event<NewEpochEvent>(
            &mut config_ref.events,
            NewEpochEvent {
                epoch: config_ref.epoch,
            },
        );
    }

    // For tests, skips the guid validation.
    #[test_only]
    public fun initialize_for_test(account: &signer) {
        system_addresses::assert_arx(account);
        move_to<Configuration>(
            account,
            Configuration {
                epoch: 0,
                last_reconfiguration_time: 0,
                events: account::new_event_handle<NewEpochEvent>(account),
            }
        );
    }

    #[test_only]
    public fun reconfigure_for_test() acquires Configuration {
        reconfigure();
    }

    // This is used together with validator::end_epoch() for testing with last_reconfiguration_time
    // It must be called each time an epoch changes
    #[test_only]
    public fun reconfigure_for_test_custom() acquires Configuration {
        let config_ref = borrow_global_mut<Configuration>(@arx);
        let current_time = timestamp::now_microseconds();
        if (current_time == config_ref.last_reconfiguration_time) {
            return
        };
        config_ref.last_reconfiguration_time = current_time;
        config_ref.epoch = config_ref.epoch + 1;
    }
}
