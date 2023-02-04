# Copyright (c) Arx
# SPDX-License-Identifier: Apache-2.0


def test_init(run_helper):
    run_helper.run_command(
        "test_init",
        ["arx", "init", "--assume-yes", "--network", "local"],
        input="\n",
    )
