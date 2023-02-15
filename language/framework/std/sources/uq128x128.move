/// Implements the Q u128 fixed point number format.
module std::uq128x128 {
    use std::u256::{Self, U256};

    const EDIVIDE_BY_ZERO: u64 = 100;

    const Q128: u128 = 340282366920938463463374607431768211455;

    // Equality enumeration.
    const EQ: u8 = 0;
    const LT: u8 = 1;
    const GT: u8 = 2;

    struct UQ128x128 has copy, store, drop {
	v: U256,
    }

    public fun from_u64(x: u64): UQ128x128 {
	let x = u256::from_u64(x);
	let q = u256::from_u128(Q128);
	UQ128x128 { v: u256::mul(x, q) }
    }

    public fun from_u128(x: u128): UQ128x128 {
	let x = u256::from_u128(x);
	let q = u256::from_u128(Q128);
	UQ128x128 { v: u256::mul(x, q) }
    }

    public fun truncate_u64(uq: UQ128x128): u64 {
	let x = u256::div(uq.v, u256::from_u128(Q128));
	u256::as_u64(x)
    }

    public fun truncate_u128(uq: UQ128x128): u128 {
	let x = u256::div(uq.v, u256::from_u128(Q128));
	u256::as_u128(x)
    }

    public fun as_u256(uq: UQ128x128): U256 {
	uq.v
    }

    public fun mul64(uq: UQ128x128, x: u64): UQ128x128 {
	let x = u256::from_u64(x);
	UQ128x128 { v: u256::mul(uq.v, x) }
    }

    public fun mul128(uq: UQ128x128, x: u128): UQ128x128 {
	let x = u256::from_u128(x);
	UQ128x128 { v: u256::mul(uq.v, x) }
    }

    public fun div64(uq: UQ128x128, x: u64): UQ128x128 {
	let x = u256::from_u64(x);
	UQ128x128 { v: u256::div(uq.v, x) }
    }

    public fun div128(uq: UQ128x128, x: u128): UQ128x128 {
	let x = u256::from_u128(x);
	UQ128x128 { v: u256::div(uq.v, x) }
    }

    public fun fraction64_64(n: u64, d: u64): UQ128x128 {
	assert!(d != 0, EDIVIDE_BY_ZERO);
        let r = u256::mul(u256::from_u64(n), u256::from_u128(Q128));
        let v = u256::div(r, u256::from_u64(d));
        UQ128x128{ v }
    }

    public fun fraction64_128(n: u64, d: u128): UQ128x128 {
	assert!(d != 0, EDIVIDE_BY_ZERO);
        let r = u256::mul(u256::from_u64(n), u256::from_u128(Q128));
        let v = u256::div(r, u256::from_u128(d));
        UQ128x128{ v }
    }

    public fun fraction128_64(n: u128, d: u64): UQ128x128 {
	assert!(d != 0, EDIVIDE_BY_ZERO);
        let r = u256::mul(u256::from_u128(n), u256::from_u128(Q128));
        let v = u256::div(r, u256::from_u64(d));
        UQ128x128{ v }
    }

    public fun fraction128_128(n: u128, d: u128): UQ128x128 {
	assert!(d != 0, EDIVIDE_BY_ZERO);
        let r = u256::mul(u256::from_u128(n), u256::from_u128(Q128));
        let v = u256::div(r, u256::from_u128(d));
        UQ128x128{ v }
    }

    public fun compare(lhs: &UQ128x128, rhs: &UQ128x128): u8 {
	if (u256::compare(&lhs.v, &rhs.v) == 0) {
	    return EQ
	} else if (u256::compare(&lhs.v, &rhs.v) == 1) {
	    return LT
	} else {
	    return GT
	}
    }

    public fun is_zero(uq: &UQ128x128): bool {
	if (u256::compare(&uq.v, &u256::zero()) == 0) {
	    return true
	} else {
	    return false
	}
    }
}
