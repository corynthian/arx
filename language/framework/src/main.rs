// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

use arx_framework::{ReleaseOptions, ReleaseTarget};
use clap::Parser;

#[derive(Parser)]
#[clap(name = "arx-framework", author, version, propagate_version = true)]
enum Commands {
    /// Creates an Arx framework release for the specified target.
    Release(StandardRelease),
    /// Allows to create a custom release package,
    Custom(CustomRelease),
}

fn main() {
    let cmd: Commands = Commands::parse();
    let result = match cmd {
        Commands::Release(release) => release.execute(),
        Commands::Custom(custom) => custom.execute(),
    };
    if let Err(e) = result {
        eprintln!("error: {:#}", e);
        std::process::exit(1)
    }
}

// ========================
// Custom Release

#[derive(Debug, Parser)]
struct CustomRelease {
    #[clap(flatten)]
    options: ReleaseOptions,
}

impl CustomRelease {
    fn execute(self) -> anyhow::Result<()> {
        self.options.create_release()
    }
}

// ========================
// Standard Release

#[derive(Debug, Parser)]
struct StandardRelease {
    /// The release target. One of head, devnet, testnet, or mainnet. Notice the type
    /// of target determines what packages are included in the release. For example,
    /// some packages may be available in testnet, but aren't in mainnet.
    #[clap(long, default_value = "head")]
    target: ReleaseTarget,

    /// Remove the source code from the release package to shrink its size.
    #[clap(long)]
    without_source_code: bool,
}

impl StandardRelease {
    fn execute(self) -> anyhow::Result<()> {
        self.target.create_release(!self.without_source_code, None)
    }
}
