// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

use arx_transactional_test_harness::run_arx_test;

datatest_stable::harness!(run_arx_test, "tests", r".*\.(mvir|move)$");
