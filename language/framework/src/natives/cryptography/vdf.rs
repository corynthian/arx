// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use move_core_types::gas_algebra::{
    InternalGas, //InternalGasPerArg, InternalGasPerByte, NumArgs, NumBytes,
};
use move_binary_format::errors::PartialVMResult;
use move_vm_runtime::native_functions::{NativeContext, NativeFunction};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    natives::function::NativeResult,
    pop_arg,
    values::Value,
};
use arx_crypto::vdf::{self, VDF};
use std::collections::VecDeque;
use smallvec::smallvec;

pub mod abort_codes {
    pub const E_LARGE_NUM_BITS: u64 = 1;
}

pub fn native_verify(
    gas_params: &GasParameters,
    _context: &mut NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 4);

    let mut cost = gas_params.base;

    // The solution prime size in bits (security parameter).
    let num_bits = pop_arg!(arguments, u16);
    // Allowing a larger number of bits is a potential DoS attack-vector.
    if num_bits > 2048 {
	return Ok(NativeResult::err(cost, abort_codes::E_LARGE_NUM_BITS));
    }

    let iterations = pop_arg!(arguments, u64);
    let solution = pop_arg!(arguments, Vec<u8>);
    let challenge = pop_arg!(arguments, Vec<u8>);
    
    let result = vdf::pietrzak(num_bits).verify(&challenge, iterations, &solution).is_ok();

    Ok(NativeResult::ok(cost, smallvec![Value::bool(result)]))
}

pub fn native_address_from_challenge(
    gas_params: &GasParameters,
    _context: &mut NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    let mut cost = gas_params.base;

    Ok(NativeResult::ok(cost, smallvec![]))
}

#[derive(Debug, Clone)]
pub struct GasParameters {
    pub base: InternalGas,
}
