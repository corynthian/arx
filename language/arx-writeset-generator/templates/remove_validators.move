script {
    use open_libra::validator_set;
    fun main(arx_root: signer) {
        {{#each addresses}}
        validator_set::remove_validator(&arx_root, @0x{{this}});
        {{/each}}
    }
}
