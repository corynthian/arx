module std::curves {
    use std::type_info;

    const EINVALID_CURVE: u64 = 1;

    /// For uncorrelated pairs (BTC / ETH).
    struct Uncorrelated {}

    /// For stable pairs (USDC / USDT).
    struct Stable {}

    /// Check provided `Curve` type is Uncorrelated.
    public fun is_uncorrelated<Curve>(): bool {
	type_info::type_of<Curve>() == type_info::type_of<Uncorrelated>()
    }

    /// Check provided `Curve` type is Stable.
    public fun is_stable<Curve>(): bool {
	type_info::type_of<Curve>() == type_info::type_of<Stable>()
    }

    /// Is `Curve` type valid or not (means correct type used).
    public fun is_valid_curve<Curve>(): bool {
        is_uncorrelated<Curve>() || is_stable<Curve>()
    }

    /// Checks if `Curve` is valid (means correct type used).
    public fun assert_valid_curve<Curve>() {
        assert!(is_valid_curve<Curve>(), EINVALID_CURVE);
    }    
}
