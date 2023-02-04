// Copyright (c) 0L
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"fmt"
	stdlib "testing/olstdlib"
	ol "testing/oltypes"
)

func demo_coin_transfer() {
	token := &ol.TypeTag__Struct{
		Value: ol.StructTag{
			Address: ol.AccountAddress(
				[32]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
			),
			Module:     ol.Identifier("ol_coin"),
			Name:       ol.Identifier("OpenLibraCoin"),
		},
	}

	to := ol.AccountAddress(
		[32]uint8{0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22,
    0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22},
	)

	amount := uint64(1_234_567)
	payload := stdlib.EncodeCoinTransfer(token, to, amount)

	call, err := stdlib.DecodeEntryFunctionPayload(payload)
	if err != nil {
		panic(fmt.Sprintf("failed to decode script: %v", err))
	}
	payment := call.(*stdlib.EntryFunctionCall__CoinTransfer)
	if payment.Amount != amount || payment.To != to {
		panic("wrong script content")
	}

	bytes, err := payload.BcsSerialize()
	if err != nil {
		panic("failed to serialize")
	}
	for _, b := range bytes {
		fmt.Printf("%d ", b)
	}
	fmt.Printf("\n")
}

func main() {
    demo_coin_transfer()
}
