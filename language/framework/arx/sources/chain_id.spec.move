spec arx::chain_id {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec initialize {
        use std::signer;
        let addr = signer::address_of(arx);
        aborts_if addr != @arx;
        aborts_if exists<ChainId>(@arx);
    }

    spec get {
        aborts_if !exists<ChainId>(@arx);
    }
}
