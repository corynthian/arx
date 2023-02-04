// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::{
    common::{
        types::{
            CliCommand, CliError, CliResult, CliTypedResult, TransactionOptions, TransactionSummary,
        },
        utils::prompt_yes_with_override,
    },
    node::get_stake_locks,
};
use arx_cached_packages::arx;
use arx_types::account_address::AccountAddress;
use async_trait::async_trait;
use clap::Parser;

/// Tool for manipulating stake and stake locks
///
#[derive(Parser)]
pub enum StakeTool {
    LockStake(LockStake),
    UnlockStake(UnlockStake),
    WithdrawStake(WithdrawStake),
    IncreaseLockup(IncreaseLockup),
    InitializeStakeOwner(InitializeStakeOwner),
    SetOperator(SetOperator),
    SetVault(SetVault),
}

impl StakeTool {
    pub async fn execute(self) -> CliResult {
        use StakeTool::*;
        match self {
            LockStake(tool) => tool.execute_serialized().await,
            UnlockStake(tool) => tool.execute_serialized().await,
            WithdrawStake(tool) => tool.execute_serialized().await,
            IncreaseLockup(tool) => tool.execute_serialized().await,
            InitializeStakeOwner(tool) => tool.execute_serialized().await,
            SetOperator(tool) => tool.execute_serialized().await,
            SetVault(tool) => tool.execute_serialized().await,
        }
    }
}

/// Add ARX to a stake lock
///
/// This command allows stake lock owners to add ARX to their stake.
#[derive(Parser)]
pub struct LockStake {
    /// Amount of Octas (10^-8 ARX) to add to stake
    #[clap(long)]
    pub amount: u64,

    #[clap(flatten)]
    pub(crate) txn_options: TransactionOptions,
}

#[async_trait]
impl CliCommand<Vec<TransactionSummary>> for LockStake {
    fn command_name(&self) -> &'static str {
        "LockStake"
    }

    async fn execute(mut self) -> CliTypedResult<Vec<TransactionSummary>> {
        let client = self
            .txn_options
            .rest_options
            .client(&self.txn_options.profile_options)?;
        let amount = self.amount;
        let owner_address = self.txn_options.sender_address()?;
        let mut transaction_summaries: Vec<TransactionSummary> = vec![];

        let stake_lock_results = get_stake_locks(&client, owner_address).await?;
        for _stake_lock in stake_lock_results {
            transaction_summaries.push(
                self.txn_options
                    .submit_transaction(arx::validator_lock_stake(amount))
                    .await
                    .map(|inner| inner.into())?,
            );
        }
        Ok(transaction_summaries)
    }
}

/// Unlock staked ARX in a stake lock
///
/// ARX coins can only be unlocked if they no longer have an applied lockup period
#[derive(Parser)]
pub struct UnlockStake {
    /// Amount of Octas (10^-8 ARX) to unlock
    #[clap(long)]
    pub amount: u64,

    #[clap(flatten)]
    pub(crate) txn_options: TransactionOptions,
}

#[async_trait]
impl CliCommand<Vec<TransactionSummary>> for UnlockStake {
    fn command_name(&self) -> &'static str {
        "UnlockStake"
    }

    async fn execute(mut self) -> CliTypedResult<Vec<TransactionSummary>> {
        let client = self
            .txn_options
            .rest_options
            .client(&self.txn_options.profile_options)?;
        let amount = self.amount;
        let owner_address = self.txn_options.sender_address()?;
        let mut transaction_summaries: Vec<TransactionSummary> = vec![];

        let stake_lock_results = get_stake_locks(&client, owner_address).await?;
        for _stake_lock in stake_lock_results {
            transaction_summaries.push(
                self.txn_options
                    .submit_transaction(arx::validator_unlock(amount))
                    .await
                    .map(|inner| inner.into())?,
            );
        }
        Ok(transaction_summaries)
    }
}

/// Withdraw unlocked staked ARX from a stake lock
///
/// This allows users to withdraw stake back into their CoinStore.
/// Before calling `WithdrawStake`, `UnlockStake` must be called first.
#[derive(Parser)]
pub struct WithdrawStake {
    /// Amount of Octas (10^-8 ARX) to withdraw.
    /// This only applies to stake locks owned directly by the owner account, instead of via
    /// a staking contract. In the latter case, when withdrawal is issued, all coins are distributed
    #[clap(long)]
    pub amount: u64,

    #[clap(flatten)]
    pub(crate) node_op_options: TransactionOptions,
}

#[async_trait]
impl CliCommand<Vec<TransactionSummary>> for WithdrawStake {
    fn command_name(&self) -> &'static str {
        "WithdrawStake"
    }

    async fn execute(mut self) -> CliTypedResult<Vec<TransactionSummary>> {
        let client = self
            .node_op_options
            .rest_options
            .client(&self.node_op_options.profile_options)?;
        let amount = self.amount;
        let owner_address = self.node_op_options.sender_address()?;
        let mut transaction_summaries: Vec<TransactionSummary> = vec![];

        let stake_lock_results = get_stake_locks(&client, owner_address).await?;
        for _stake_lock in stake_lock_results {
            transaction_summaries.push(
                self.node_op_options
                    .submit_transaction(arx::validator_withdraw(amount))
                    .await
                    .map(|inner| inner.into())?,
            );
        }
        Ok(transaction_summaries)
    }
}

/// Increase lockup of all staked ARX in a stake lock
///
/// Lockup may need to be increased in order to vote on a proposal.
#[derive(Parser)]
pub struct IncreaseLockup {
    #[clap(flatten)]
    pub(crate) txn_options: TransactionOptions,
}

#[async_trait]
impl CliCommand<Vec<TransactionSummary>> for IncreaseLockup {
    fn command_name(&self) -> &'static str {
        "IncreaseLockup"
    }

    async fn execute(mut self) -> CliTypedResult<Vec<TransactionSummary>> {
        let client = self
            .txn_options
            .rest_options
            .client(&self.txn_options.profile_options)?;
        let owner_address = self.txn_options.sender_address()?;
        let mut transaction_summaries: Vec<TransactionSummary> = vec![];

        let stake_lock_results = get_stake_locks(&client, owner_address).await?;
        for _stake_lock in stake_lock_results {
            transaction_summaries.push(
                self.txn_options
                    .submit_transaction(arx::validator_increase_lockup())
                    .await
                    .map(|inner| inner.into())?,
            );
        }
        Ok(transaction_summaries)
    }
}

/// Initialize a stake lock owner
///
/// Initializing stake owner adds the capability to delegate the
/// stake lock to an operator, or delegate voting to a different account.
#[derive(Parser)]
pub struct InitializeStakeOwner {
    /// Initial amount of Octas (10^-8 ARX) to be staked
    #[clap(long)]
    pub initial_stake_amount: u64,

    /// Account Address of delegated operator
    #[clap(long, parse(try_from_str=crate::common::types::load_account_arg))]
    pub operator_address: Option<AccountAddress>,

    /// Account address of delegated vault
    #[clap(long, parse(try_from_str=crate::common::types::load_account_arg))]
    pub vault_address: Option<AccountAddress>,

    #[clap(flatten)]
    pub(crate) txn_options: TransactionOptions,
}

#[async_trait]
impl CliCommand<TransactionSummary> for InitializeStakeOwner {
    fn command_name(&self) -> &'static str {
        "InitializeStakeOwner"
    }

    async fn execute(mut self) -> CliTypedResult<TransactionSummary> {
        let owner_address = self.txn_options.sender_address()?;
        self.txn_options
            .submit_transaction(arx::validator_initialize_stake_owner(
                self.initial_stake_amount,
                self.operator_address.unwrap_or(owner_address),
                self.vault_address.unwrap_or(owner_address),
            ))
            .await
            .map(|inner| inner.into())
    }
}

/// Delegate operator capability from the current operator to another account
///
/// By default, the operator of a stake lock is the owner of the stake lock
#[derive(Parser)]
pub struct SetOperator {
    /// Account Address of delegated operator
    ///
    /// If not specified, it will be the same as the owner
    #[clap(long, parse(try_from_str=crate::common::types::load_account_arg))]
    pub operator_address: AccountAddress,

    #[clap(flatten)]
    pub(crate) txn_options: TransactionOptions,
}

#[async_trait]
impl CliCommand<Vec<TransactionSummary>> for SetOperator {
    fn command_name(&self) -> &'static str {
        "SetOperator"
    }

    async fn execute(mut self) -> CliTypedResult<Vec<TransactionSummary>> {
        let client = self
            .txn_options
            .rest_options
            .client(&self.txn_options.profile_options)?;
        let owner_address = self.txn_options.sender_address()?;
        let new_operator_address = self.operator_address;
        let mut transaction_summaries: Vec<TransactionSummary> = vec![];

        let stake_lock_results = get_stake_locks(&client, owner_address).await?;
        for _stake_lock in stake_lock_results {
            transaction_summaries.push(
                self.txn_options
                    .submit_transaction(arx::validator_set_operator(
                        new_operator_address,
                    ))
                    .await
                    .map(|inner| inner.into())?,
            );
        }
        Ok(transaction_summaries)
    }
}

/// Set the vault which earns the staking rewards.
///
/// By default, the vault of a stake lock is the owner of the stake lock
#[derive(Parser)]
pub struct SetVault {
    /// Account Address of the vault
    ///
    /// If not specified, it will be the same as the owner
    #[clap(long, parse(try_from_str=crate::common::types::load_account_arg))]
    pub vault_address: AccountAddress,

    #[clap(flatten)]
    pub(crate) txn_options: TransactionOptions,
}

#[async_trait]
impl CliCommand<Vec<TransactionSummary>> for SetVault {
    fn command_name(&self) -> &'static str {
        "SetVault"
    }

    async fn execute(mut self) -> CliTypedResult<Vec<TransactionSummary>> {
        let client = self
            .txn_options
            .rest_options
            .client(&self.txn_options.profile_options)?;
        let owner_address = self.txn_options.sender_address()?;
        let new_vault_address = self.vault_address;
        let mut transaction_summaries: Vec<TransactionSummary> = vec![];

        let stake_lock_results = get_stake_locks(&client, owner_address).await?;
        for _stake_lock in stake_lock_results {
            transaction_summaries.push(
                self.txn_options
                    .submit_transaction(arx::validator_set_vault(
                        new_vault_address,
                    ))
                    .await
                    .map(|inner| inner.into())?,
            );
        }
        Ok(transaction_summaries)
    }
}

