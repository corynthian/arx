// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::{account_address::AccountAddress, event::EventHandle};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct StakeLock {
    pub active: u64,
    pub inactive: u64,
    pub pending_active: u64,
    pub pending_inactive: u64,
    pub locked_until_secs: u64,
    pub operator_address: AccountAddress,
    pub vault_address: AccountAddress,

    pub register_validator_events: EventHandle,
    pub set_operator_events: EventHandle,
    pub lock_stake_events: EventHandle,
    pub reactivate_stake_events: EventHandle,
    pub rotate_consensus_key_events: EventHandle,
    pub update_network_info_events: EventHandle,
    pub increase_lockup_events: EventHandle,
    pub join_validator_set_events: EventHandle,
    pub distribute_rewards_events: EventHandle,
    pub unlock_stake_events: EventHandle,
    pub withdraw_stake_events: EventHandle,
    pub leave_validator_set_events: EventHandle,
}

impl StakeLock {
    pub fn get_total_staked_amount(&self) -> u64 {
        self.active + self.inactive + self.pending_active + self.pending_inactive
    }

    pub fn get_governance_voting_power(&self) -> u64 {
        self.active + self.pending_active + self.pending_inactive
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RegisterValidatorEvent {
    pub lock_address: AccountAddress,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SetOperatorEvent {
    pub lock_address: AccountAddress,
    pub old_operator: AccountAddress,
    pub new_operator: AccountAddress,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LockStakeEvent {
    pub lock_address: AccountAddress,
    pub amount_added: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ReactivateStakeEvent {
    pub lock_address: AccountAddress,
    pub amount: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RotateConsensusKeyEvent {
    pub lock_address: AccountAddress,
    pub old_consensus_pubkey: Vec<u8>,
    pub new_consensus_pubkey: Vec<u8>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UpdateNetworkInfoEvent {
    pub lock_address: AccountAddress,
    pub old_network_addresses: Vec<u8>,
    pub new_network_addresses: Vec<u8>,
    pub old_fullnode_addresses: Vec<u8>,
    pub new_fullnode_addresses: Vec<u8>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct IncreaseLockupEvent {
    pub lock_address: AccountAddress,
    pub old_locked_until_secs: u64,
    pub new_locked_until_secs: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct JoinValidatorSetEvent {
    pub lock_address: AccountAddress,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DistributeRewardsEvent {
    pub lock_address: AccountAddress,
    pub rewards_amount: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UnlockStakeEvent {
    pub lock_address: AccountAddress,
    pub amount_unlocked: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct WithdrawStakeEvent {
    pub lock_address: AccountAddress,
    pub amount_withdrawn: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LeaveValidatorSetEvent {
    pub lock_address: AccountAddress,
}
