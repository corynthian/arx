/// Contains functions which deal with coin type checking and comparison.
module arx::coin_type {
    use std::option;
    use std::string::{Self, String};
    use std::comparator::{Self, Result};
    use std::type_info;
    use std::curves::is_stable;
    use std::math64;

    use arx::coin;

    // Errors codes.

    /// When both coins have the same name and cannot be ordered.
    const ESAME_COIN: u64 = 3000;

    /// When provided CoinType is not a coin.
    const ENOT_A_COIN: u64 = 3001;

    // Constants.

    /// Length of symbol prefix to be used in LP coin symbol.
    const SYMBOL_PREFIX_LENGTH: u64 = 4;

    /// Check if provided generic `CoinType` is a coin.
    public fun assert_coin_initialized<CoinType>() {
        assert!(coin::is_coin_initialized<CoinType>(), ENOT_A_COIN);
    }

    /// Compare two coins, `X` and `Y`, using names.
    /// Caller should call this function to determine the order of X, Y.
    public fun compare<X, Y>(): Result {
        let x_info = type_info::type_of<X>();
        let y_info = type_info::type_of<Y>();

        // 1. compare struct_name
        let x_struct_name = type_info::struct_name(&x_info);
        let y_struct_name = type_info::struct_name(&y_info);
        let struct_cmp = comparator::compare(&x_struct_name, &y_struct_name);
        if (!comparator::is_equal(&struct_cmp)) return struct_cmp;

        // 2. if struct names are equal, compare module name
        let x_module_name = type_info::module_name(&x_info);
        let y_module_name = type_info::module_name(&y_info);
        let module_cmp = comparator::compare(&x_module_name, &y_module_name);
        if (!comparator::is_equal(&module_cmp)) return module_cmp;

        // 3. if modules are equal, compare addresses
        let x_address = type_info::account_address(&x_info);
        let y_address = type_info::account_address(&y_info);
        let address_cmp = comparator::compare(&x_address, &y_address);

        address_cmp
    }

    /// Check that coins generics `X`, `Y` are sorted in correct ordering.
    /// X != Y && X.symbol < Y.symbol
    public fun preserves_ordering<X, Y>(): bool {
        let order = compare<X, Y>();
        assert!(!comparator::is_equal(&order), ESAME_COIN);
        comparator::is_smaller_than(&order)
    }

    /// Get supply for `CoinType`.
    /// Would throw error if supply for `CoinType` doesn't exist.
    public fun supply<CoinType>(): u128 {
        option::extract(&mut coin::supply<CoinType>())
    }

    /// Generate LP coin name and symbol for pair `X`/`Y` and curve `Curve`.
    /// ```
    /// (curve_name, curve_symbol) = when(curve) {
    ///     is Uncorrelated -> ("::U", "(no symbol)")
    ///     is Stable -> ("::S", "*")
    /// }
    /// name = "LP::" + symbol<X>() + "-" + symbol<Y>() + curve_name;
    /// symbol = symbol<X>()[0:4] + "-" + symbol<Y>()[0:4] + curve_symbol;
    /// ```
    /// For example, for `LP<BTC, USDT, Uncorrelated>`,
    /// the result will be `(b"LP::BTC-USDT::U", b"BTC-USDT")`
    public fun generate_lp_name_and_symbol<X, Y, Curve>(): (String, String) {
        let lp_name = string::utf8(b"");
        string::append_utf8(&mut lp_name, b"LP::");
        string::append(&mut lp_name, coin::symbol<X>());
        string::append_utf8(&mut lp_name, b"-");
        string::append(&mut lp_name, coin::symbol<Y>());

        let lp_symbol = string::utf8(b"");
        string::append(&mut lp_symbol, coin_symbol_prefix<X>());
        string::append_utf8(&mut lp_symbol, b"-");
        string::append(&mut lp_symbol, coin_symbol_prefix<Y>());

        let (curve_name, curve_symbol) =
	    if (is_stable<Curve>()) {
		(b"::S", b"*")
	    } else {
		(b"::U", b"")
	    };
        string::append_utf8(&mut lp_name, curve_name);
        string::append_utf8(&mut lp_symbol, curve_symbol);

        (lp_name, lp_symbol)
    }

    fun coin_symbol_prefix<CoinType>(): String {
        let symbol = coin::symbol<CoinType>();
        let prefix_length = math64::min(string::length(&symbol), SYMBOL_PREFIX_LENGTH);
        string::sub_string(&symbol, 0, prefix_length)
    }
}
