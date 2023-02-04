script {
    use open_libra::parallel_execution_config;
    fun main(arx_root: signer, _execute_as: signer) {
        parallel_execution_config::disable_parallel_execution(&arx_root);
    }
}
