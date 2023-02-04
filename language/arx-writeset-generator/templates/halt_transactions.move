script {
    use open_libra::transaction_publishing_option;
    fun main(arx_root: signer) {
        transaction_publishing_option::halt_all_transactions(&arx_root);
    }
}
