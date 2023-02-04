// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

//! This module defines error types used by [`ArxDB`](crate::ArxDB).

use thiserror::Error;

/// This enum defines errors commonly used among [`ArxDB`](crate::ArxDB) APIs.
#[derive(Debug, Error)]
pub enum ArxDbError {
    /// A requested item is not found.
    #[error("{0} not found.")]
    NotFound(String),
    /// Requested too many items.
    #[error("Too many items requested: at least {0} requested, max is {1}")]
    TooManyRequested(u64, u64),
}
