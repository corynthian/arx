// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

/* eslint-disable max-len */
import nacl from "tweetnacl";
import { bytesToHex, hexToBytes } from "@noble/hashes/utils";
import { bcsSerializeUint64, bcsToBytes, Bytes } from "../bcs";
import { HexString } from "../hex_string";

import { TransactionBuilderEd25519, TransactionBuilder } from "./index";
import {
  AccountAddress,
  ChainId,
  Ed25519Signature,
  RawTransaction,
  Script,
  EntryFunction,
  StructTag,
  TransactionArgumentAddress,
  TransactionArgumentU8,
  TransactionArgumentU8Vector,
  TransactionPayloadScript,
  TransactionPayloadEntryFunction,
  TypeTagStruct,
  TransactionArgumentU16,
  TransactionArgumentU32,
  TransactionArgumentU256,
} from "../arx_types";

const ADDRESS_1 = "0x1222";
const ADDRESS_2 = "0xdd";
const ADDRESS_3 = "0x0a550c18";
const ADDRESS_4 = "0x01";
const PRIVATE_KEY = "9bf49a6a0755f953811fce125f2683d50429c3bb49e074147e0089a52eae155f";
const TXN_EXPIRE = "18446744073709551615";

function hexSignedTxn(signedTxn: Uint8Array): string {
  return bytesToHex(signedTxn);
}

function sign(rawTxn: RawTransaction): Bytes {
  const privateKeyBytes = new HexString(PRIVATE_KEY).toUint8Array();
  const signingKey = nacl.sign.keyPair.fromSeed(privateKeyBytes.slice(0, 32));
  const { publicKey } = signingKey;

  const txnBuilder = new TransactionBuilderEd25519(
    (signingMessage) => new Ed25519Signature(nacl.sign(signingMessage, signingKey.secretKey).slice(0, 64)),
    publicKey,
  );

  return txnBuilder.sign(rawTxn);
}

test("throws when preparing signing message with invalid payload", () => {
  expect(() => {
    // @ts-ignore
    TransactionBuilder.getSigningMessage("invalid");
  }).toThrow("Unknown transaction type.");
});

test("serialize entry function payload with no type args", () => {
  const entryFunctionPayload = new TransactionPayloadEntryFunction(
    EntryFunction.natural(
      `${ADDRESS_1}::arx_coin`,
      "transfer",
      [],
      [bcsToBytes(AccountAddress.fromHex(ADDRESS_2)), bcsSerializeUint64(1)],
    ),
  );

  const rawTxn = new RawTransaction(
    AccountAddress.fromHex(new HexString(ADDRESS_3)),
    BigInt(0),
    entryFunctionPayload,
    BigInt(2000),
    BigInt(0),
    BigInt(TXN_EXPIRE),
    new ChainId(4),
  );

  const signedTxn = sign(rawTxn);

  expect(hexSignedTxn(signedTxn)).toBe(
    "000000000000000000000000000000000000000000000000000000000a550c180000000000000000020000000000000000000000000000000000000000000000000000000000001222086172785f636f696e087472616e7366657200022000000000000000000000000000000000000000000000000000000000000000dd080100000000000000d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a49200408d8ae09484cbca81dc1b6e89ebc8b57467e37131310693b5c46ea236d075c494fe634b86730bd90551cca7fd6001c91243cef91610ae330e1cc7045d2a19770c",
  );
});

test("serialize entry function payload with type args", () => {
  const token = new TypeTagStruct(StructTag.fromString(`${ADDRESS_4}::arx_coin::ArxCoin`));

  const entryFunctionPayload = new TransactionPayloadEntryFunction(
    EntryFunction.natural(
      `${ADDRESS_1}::coin`,
      "transfer",
      [token],
      [bcsToBytes(AccountAddress.fromHex(ADDRESS_2)), bcsSerializeUint64(1)],
    ),
  );

  const rawTxn = new RawTransaction(
    AccountAddress.fromHex(ADDRESS_3),
    BigInt(0),
    entryFunctionPayload,
    BigInt(2000),
    BigInt(0),
    BigInt(TXN_EXPIRE),
    new ChainId(4),
  );

  const signedTxn = sign(rawTxn);

  expect(hexSignedTxn(signedTxn)).toBe(
    "000000000000000000000000000000000000000000000000000000000a550c18000000000000000002000000000000000000000000000000000000000000000000000000000000122204636f696e087472616e7366657201070000000000000000000000000000000000000000000000000000000000000001086172785f636f696e07417278436f696e00022000000000000000000000000000000000000000000000000000000000000000dd080100000000000000d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a4920040f2acf75c6d0d3787b8c32a39f3d903dabfcedbbf2d6e0a85b8054848408fb2acc160993473d4fb6553c80bec2d7835ce5788f7a6a51a1795de871f308ce66c0c",
  );
});

test("serialize entry function payload with type args but no function args", () => {
  const token = new TypeTagStruct(StructTag.fromString(`${ADDRESS_4}::arx_coin::ArxCoin`));

  const entryFunctionPayload = new TransactionPayloadEntryFunction(
    EntryFunction.natural(`${ADDRESS_1}::coin`, "fake_func", [token], []),
  );

  const rawTxn = new RawTransaction(
    AccountAddress.fromHex(ADDRESS_3),
    BigInt(0),
    entryFunctionPayload,
    BigInt(2000),
    BigInt(0),
    BigInt(TXN_EXPIRE),
    new ChainId(4),
  );

  const signedTxn = sign(rawTxn);

  expect(hexSignedTxn(signedTxn)).toBe(
    "000000000000000000000000000000000000000000000000000000000a550c18000000000000000002000000000000000000000000000000000000000000000000000000000000122204636f696e0966616b655f66756e6301070000000000000000000000000000000000000000000000000000000000000001086172785f636f696e07417278436f696e0000d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a492004020259239cd0bd61527bb84fa7d9d712ea6190f53ecd8e8d21a9a844c16cfaa4e24b69bee95690b2c1e2febe215eafdedacc38f64711d210784a518b44d12f206",
  );
});

test("serialize script payload with no type args and no function args", () => {
  const script = hexToBytes("a11ceb0b030000000105000100000000050601000000000000000600000000000000001a0102");

  const scriptPayload = new TransactionPayloadScript(new Script(script, [], []));

  const rawTxn = new RawTransaction(
    AccountAddress.fromHex(ADDRESS_3),
    BigInt(0),
    scriptPayload,
    BigInt(2000),
    BigInt(0),
    BigInt(TXN_EXPIRE),
    new ChainId(4),
  );

  const signedTxn = sign(rawTxn);

  expect(hexSignedTxn(signedTxn)).toBe(
    "000000000000000000000000000000000000000000000000000000000a550c1800000000000000000026a11ceb0b030000000105000100000000050601000000000000000600000000000000001a01020000d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a49200405a0ecc9bd50c103bb632e6cf9d924e83be6103aa1360ff93f2ba1a88a48ad7788e17392fddef5ea85347b73fe01e657de1421edde8e6e16ec429251264960b07",
  );
});

test("serialize script payload with type args but no function args", () => {
  const token = new TypeTagStruct(StructTag.fromString(`${ADDRESS_4}::arx_coin::ArxCoin`));

  const script = hexToBytes("a11ceb0b030000000105000100000000050601000000000000000600000000000000001a0102");

  const scriptPayload = new TransactionPayloadScript(new Script(script, [token], []));

  const rawTxn = new RawTransaction(
    AccountAddress.fromHex(ADDRESS_3),
    BigInt(0),
    scriptPayload,
    BigInt(2000),
    BigInt(0),
    BigInt(TXN_EXPIRE),
    new ChainId(4),
  );

  const signedTxn = sign(rawTxn);

  expect(hexSignedTxn(signedTxn)).toBe(
    "000000000000000000000000000000000000000000000000000000000a550c1800000000000000000026a11ceb0b030000000105000100000000050601000000000000000600000000000000001a010201070000000000000000000000000000000000000000000000000000000000000001086172785f636f696e07417278436f696e0000d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a492004003a4bec44e308e56ade3fdd913b815d1701ce56cd50cfc420a9c432755bcb851b1d076442d892a6df1f75b4cd73629768b2d4e355878ee6094ed547d79ee5b04",
  );
});

test("serialize script payload with type arg and function arg", () => {
  const token = new TypeTagStruct(StructTag.fromString(`${ADDRESS_4}::arx_coin::ArxCoin`));

  const argU8 = new TransactionArgumentU8(2);

  const script = hexToBytes("a11ceb0b030000000105000100000000050601000000000000000600000000000000001a0102");

  const scriptPayload = new TransactionPayloadScript(new Script(script, [token], [argU8]));
  const rawTxn = new RawTransaction(
    AccountAddress.fromHex(ADDRESS_3),
    BigInt(0),
    scriptPayload,
    BigInt(2000),
    BigInt(0),
    BigInt(TXN_EXPIRE),
    new ChainId(4),
  );

  const signedTxn = sign(rawTxn);

  expect(hexSignedTxn(signedTxn)).toBe(
    "000000000000000000000000000000000000000000000000000000000a550c1800000000000000000026a11ceb0b030000000105000100000000050601000000000000000600000000000000001a010201070000000000000000000000000000000000000000000000000000000000000001086172785f636f696e07417278436f696e00010002d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a4920040b90020aa1edb10695708c36cd01e274d62cf8d95729ab3400bb4b2e3291fca65ada634da955acaef9eb492fef616c91c944019a43d97c2bda9ee27f95ee0580b",
  );
});

test("serialize script payload with one type arg and two function args", () => {
  const token = new TypeTagStruct(StructTag.fromString(`${ADDRESS_4}::arx_coin::ArxCoin`));

  const argU8Vec = new TransactionArgumentU8Vector(bcsSerializeUint64(1));
  const argAddress = new TransactionArgumentAddress(AccountAddress.fromHex("0x01"));

  const script = hexToBytes("a11ceb0b030000000105000100000000050601000000000000000600000000000000001a0102");

  const scriptPayload = new TransactionPayloadScript(new Script(script, [token], [argU8Vec, argAddress]));

  const rawTxn = new RawTransaction(
    AccountAddress.fromHex(ADDRESS_3),
    BigInt(0),
    scriptPayload,
    BigInt(2000),
    BigInt(0),
    BigInt(TXN_EXPIRE),
    new ChainId(4),
  );

  const signedTxn = sign(rawTxn);

  expect(hexSignedTxn(signedTxn)).toBe(
    "000000000000000000000000000000000000000000000000000000000a550c1800000000000000000026a11ceb0b030000000105000100000000050601000000000000000600000000000000001a010201070000000000000000000000000000000000000000000000000000000000000001086172785f636f696e07417278436f696e000204080100000000000000030000000000000000000000000000000000000000000000000000000000000001d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a4920040a5b3e1eccb290c22f9a657d980df8d15ac448310a9ad10bf41d520dfd480a6d84fbaeec4623b204c7d5e3851de45ffd08a48e624645241b9fdfa51326e578c0c",
  );
});

test("serialize script payload with new integer types (u16, u32, u256) as args", () => {
  const argU16 = new TransactionArgumentU16(0xf111);
  const argU32 = new TransactionArgumentU32(0xf1111111);
  const argU256 = new TransactionArgumentU256(
    BigInt("0xf111111111111111111111111111111111111111111111111111111111111111"),
  );

  const script = hexToBytes("");

  const scriptPayload = new TransactionPayloadScript(new Script(script, [], [argU16, argU32, argU256]));

  const rawTxn = new RawTransaction(
    AccountAddress.fromHex(ADDRESS_3),
    BigInt(0),
    scriptPayload,
    BigInt(2000),
    BigInt(0),
    BigInt(TXN_EXPIRE),
    new ChainId(4),
  );

  const signedTxn = sign(rawTxn);

  expect(hexSignedTxn(signedTxn)).toBe(
    "000000000000000000000000000000000000000000000000000000000a550c180000000000000000000000030611f107111111f10811111111111111111111111111111111111111111111111111111111111111f1d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a49200403475d33b805c26be149ea98e5b84f7a4e5f66c8121d8b7d877508b2f5065563007742db42fb8c216399f2b1258da4dd77c195caa208a554d96ac6057bbe68f05",
  );
});
