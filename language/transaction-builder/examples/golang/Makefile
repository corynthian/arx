# Copyright (c) 0L
# SPDX-License-Identifier: Apache-2.0

clean:
	- rm -rf go.mod go.sum olstdlib oltypes

test:
	cargo run -p ol-framework release
	cargo run -p ol-transaction-builder -- \
		--language go --module-name olstdlib \
		--package-name testing \
		--with-ol-types "../../../../testsuite/generate-format/tests/staged/ol.yaml" \
		--target-source-dir . \
		"../../../framework/ol-framework/build/OLFramework"
	- go mod init testing
	go mod edit -replace testing=`pwd`
	go get github.com/corynthian/serde-reflection/serde-generate/runtime/golang/bcs
	go get github.com/corynthian/serde-reflection/serde-generate/runtime/golang/serde
	go run stdlib_demo.go

.PHONY: clean test
