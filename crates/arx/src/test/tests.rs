// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use crate::{
    move_tool::{ArgWithType, FunctionArgType},
    CliResult, Tool,
};
use clap::Parser;
use std::str::FromStr;

/// In order to ensure that there aren't duplicate input arguments for untested CLI commands,
/// we call help on every command to ensure it at least runs
#[tokio::test]
async fn ensure_every_command_args_work() {
    assert_cmd_not_panic(&["arx"]).await;

    assert_cmd_not_panic(&["arx", "account"]).await;
    assert_cmd_not_panic(&["arx", "account", "create", "--help"]).await;
    assert_cmd_not_panic(&["arx", "account", "create-resource-account", "--help"]).await;
    assert_cmd_not_panic(&["arx", "account", "fund-with-faucet", "--help"]).await;
    assert_cmd_not_panic(&["arx", "account", "list", "--help"]).await;
    assert_cmd_not_panic(&["arx", "account", "lookup-address", "--help"]).await;
    assert_cmd_not_panic(&["arx", "account", "rotate-key", "--help"]).await;
    assert_cmd_not_panic(&["arx", "account", "transfer", "--help"]).await;

    assert_cmd_not_panic(&["arx", "config"]).await;
    assert_cmd_not_panic(&["arx", "config", "generate-shell-completions", "--help"]).await;
    assert_cmd_not_panic(&["arx", "config", "init", "--help"]).await;
    assert_cmd_not_panic(&["arx", "config", "set-global-config", "--help"]).await;
    assert_cmd_not_panic(&["arx", "config", "show-global-config"]).await;
    assert_cmd_not_panic(&["arx", "config", "show-profiles"]).await;

    assert_cmd_not_panic(&["arx", "genesis"]).await;
    assert_cmd_not_panic(&["arx", "genesis", "generate-genesis", "--help"]).await;
    assert_cmd_not_panic(&["arx", "genesis", "generate-keys", "--help"]).await;
    assert_cmd_not_panic(&["arx", "genesis", "generate-layout-template", "--help"]).await;
    assert_cmd_not_panic(&["arx", "genesis", "set-validator-configuration", "--help"]).await;
    assert_cmd_not_panic(&["arx", "genesis", "setup-git", "--help"]).await;
    assert_cmd_not_panic(&["arx", "genesis", "generate-admin-write-set", "--help"]).await;

    assert_cmd_not_panic(&["arx", "governance"]).await;
    assert_cmd_not_panic(&["arx", "governance", "execute-proposal", "--help"]).await;
    assert_cmd_not_panic(&["arx", "governance", "generate-upgrade-proposal", "--help"]).await;
    assert_cmd_not_panic(&["arx", "governance", "propose", "--help"]).await;
    assert_cmd_not_panic(&["arx", "governance", "vote", "--help"]).await;

    assert_cmd_not_panic(&["arx", "info"]).await;

    assert_cmd_not_panic(&["arx", "init", "--help"]).await;

    assert_cmd_not_panic(&["arx", "key"]).await;
    assert_cmd_not_panic(&["arx", "key", "generate", "--help"]).await;
    assert_cmd_not_panic(&["arx", "key", "extract-peer", "--help"]).await;

    assert_cmd_not_panic(&["arx", "move"]).await;
    assert_cmd_not_panic(&["arx", "move", "clean", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "compile", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "download", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "init", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "list", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "prove", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "publish", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "run", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "run-script", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "test", "--help"]).await;
    assert_cmd_not_panic(&["arx", "move", "transactional-test", "--help"]).await;

    assert_cmd_not_panic(&["arx", "node"]).await;
    assert_cmd_not_panic(&["arx", "node", "get-stake-pool", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "analyze-validator-performance", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "bootstrap-db-from-backup", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "initialize-validator", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "join-validator-set", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "leave-validator-set", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "run-local-testnet", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "show-validator-config", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "show-validator-set", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "show-validator-stake", "--help"]).await;
    assert_cmd_not_panic(&["arx", "node", "update-consensus-key", "--help"]).await;
    assert_cmd_not_panic(&[
        "arx",
        "node",
        "update-validator-network-addresses",
        "--help",
    ])
    .await;

    assert_cmd_not_panic(&["arx", "stake"]).await;
    assert_cmd_not_panic(&["arx", "stake", "add-stake", "--help"]).await;
    assert_cmd_not_panic(&["arx", "stake", "increase-lockup", "--help"]).await;
    assert_cmd_not_panic(&["arx", "stake", "initialize-stake-owner", "--help"]).await;
    assert_cmd_not_panic(&["arx", "stake", "set-delegated-voter", "--help"]).await;
    assert_cmd_not_panic(&["arx", "stake", "set-operator", "--help"]).await;
    assert_cmd_not_panic(&["arx", "stake", "unlock-stake", "--help"]).await;
    assert_cmd_not_panic(&["arx", "stake", "withdraw-stake", "--help"]).await;
}

/// Ensure we can parse URLs for args
#[tokio::test]
async fn ensure_can_parse_args_with_urls() {
    let result = ArgWithType::from_str("string:https://arxlabs.com").unwrap();
    matches!(result._ty, FunctionArgType::String);
    assert_eq!(
        result.arg,
        bcs::to_bytes(&"https://arxlabs.com".to_string()).unwrap()
    );
}

async fn assert_cmd_not_panic(args: &[&str]) {
    // When a command fails, it will have a panic in it due to an improperly setup command
    // thread 'main' panicked at 'Command propose: Argument names must be unique, but 'assume-yes' is
    // in use by more than one argument or group', ...

    match run_cmd(args).await {
        Ok(inner) => assert!(
            !inner.contains("panic"),
            "Failed to not panic cmd {}: {}",
            args.join(" "),
            inner
        ),
        Err(inner) => assert!(
            !inner.contains("panic"),
            "Failed to not panic cmd {}: {}",
            args.join(" "),
            inner
        ),
    }
}

async fn run_cmd(args: &[&str]) -> CliResult {
    let tool: Tool = Tool::try_parse_from(args).map_err(|msg| msg.to_string())?;
    tool.execute().await
}
