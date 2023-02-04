// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::{
    common::{
        types::PromptOptions,
        utils::{dir_default_to_current, write_to_file},
    },
    genesis::{
        get_validator_configs,
	// ARX-TODO: Remove EMPLOYEE_FILE from genesis git
        git::{GitOptions, LAYOUT_FILE},
        parse_error,
    },
    CliCommand, CliTypedResult,
};
use arx_genesis::config::Layout;
use arx_sdk::move_types::account_address::AccountAddress;
use async_trait::async_trait;
use clap::Parser;
use std::{
    collections::BTreeMap,
    path::{Path, PathBuf},
};

const STAKE_LOCK_ADDRESSES: &str = "stake-lock-addresses.yaml";

/// Get stake lock addresses from a mainnet genesis setup
///
/// Outputs all lock addresses to a file from the genesis files
#[derive(Parser)]
pub struct StakeLockAddresses {
    #[clap(long, parse(from_os_str))]
    output_dir: Option<PathBuf>,

    #[clap(flatten)]
    prompt_options: PromptOptions,
    #[clap(flatten)]
    git_options: GitOptions,
}

#[async_trait]
impl CliCommand<Vec<PathBuf>> for StakeLockAddresses {
    fn command_name(&self) -> &'static str {
        "GetStakeLockAddresses"
    }

    async fn execute(self) -> CliTypedResult<Vec<PathBuf>> {
        let output_dir = dir_default_to_current(self.output_dir.clone())?;
        let client = self.git_options.get_client()?;
        let layout: Layout = client.get(Path::new(LAYOUT_FILE))?;
        let validators = get_validator_configs(&client, &layout, true).map_err(parse_error)?;

        let mut address_to_lock = BTreeMap::<AccountAddress, AccountAddress>::new();

        for validator in validators {
            let stake_lock_address = validator.owner_account_address.into();
            address_to_lock.insert(validator.owner_account_address.into(), stake_lock_address);
        }

        let stake_lock_addresses_file = output_dir.join(STAKE_LOCK_ADDRESSES);

        write_to_file(
            stake_lock_addresses_file.as_path(),
            STAKE_LOCK_ADDRESSES,
            serde_yaml::to_string(&address_to_lock)?.as_bytes(),
        )?;

        Ok(vec![stake_lock_addresses_file])
    }
}
