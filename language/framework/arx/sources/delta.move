module arx::delta {
    // Delta enumeration

    /// Delta zero
    const DELTA_EQUAL: u64 = 0;
    /// Delta positive sign
    const DELTA_POSITIVE: u64 = 1;
    /// Delta negative sign
    const DELTA_NEGATIVE: u64 = 2;

    /// Represents the time weighted average reserve of X in the last epoch.
    struct Delta has drop {
	/// Whether X > Y, Y > X or X = Y
	sign: u64,
	/// The cumulative difference in X vs Y
	value: u64,
    }
    public fun create(sign: u64, value: u64): Delta {
	Delta { sign, value }
    }
    public fun get_delta_sign(delta: &Delta): u64 {
	delta.sign
    }
    public fun get_delta_value(delta: &Delta): u64 {
	delta.value
    }
}
