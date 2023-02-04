/// Provides a common place for exporting `create_signer` across the Open Libra modules.
///
/// To use create_signer, add the module below, such that:
/// `friend arx::friend_wants_create_signer`
/// where `friend_wants_create_signer` is the module that needs `create_signer`.
///
/// Note, that this is only available within the Open Libra modules.
///
/// This exists to make auditing straight forward and to limit the need to depend
/// on account to have access to this.
module arx::create_signer {
    friend arx::account;
    friend arx::arx_account;
    friend arx::genesis;
    friend arx::object;

    public(friend) native fun create_signer(addr: address): signer;
}
