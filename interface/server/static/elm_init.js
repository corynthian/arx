// Constants
const NODE_URL = 'http://localhost:8080';
const FAUCET_URL = 'http://localhost:8081';
// Local storage key.
const ACCOUNT_LOCAL_STORAGE_KEY = 'ARX_ACCOUNT_0';

// Pull in the Arx SDK.
const Arx = window.arxSDK;

// Create a new faucet client.
const Faucet = new Arx.FaucetClient(NODE_URL, FAUCET_URL);

// Start the elm application.
var app = Elm.Main.init({
    node: document.getElementById('elmMain')
});

// Request to join the subsidialis with a solaris of `ArxCoin` type.
async function subsidialisJoin(arxAccount) {
    const client = new Arx.ArxClient(NODE_URL);
    const coinType = new Arx.TxnBuilderTypes.TypeTagStruct(
	Arx.TxnBuilderTypes.StructTag.fromString("0x1::arx_coin::ArxCoin")
    );
    const entryFunctionPayload = new Arx.TxnBuilderTypes.TransactionPayloadEntryFunction(
	Arx.TxnBuilderTypes.EntryFunction.natural(
	    "0x1::subsidialis",
	    "join",
	    [coinType],
	    [],
	),
    );
    const rawTxn = await client.generateRawTransaction(arxAccount.address(), entryFunctionPayload);
    const bcsTxn = Arx.ArxClient.generateBCSTransaction(arxAccount, rawTxn);
    const transactionResult = await client.submitSignedBCSTransaction(bcsTxn);
    await client.waitForTransaction(transactionResult.hash);
    return transactionResult.hash;
}

// Add `ArxCoin`s to an existing solaris within the subsidialis.
async function subsidialisAddCoins(arxAccount, amount) {
    const client = new Arx.ArxClient(NODE_URL);
    const coinType = new Arx.TxnBuilderTypes.TypeTagStruct(
	Arx.TxnBuilderTypes.StructTag.fromString("0x1::arx_coin::ArxCoin")
    );
    const entryFunctionPayload = new Arx.TxnBuilderTypes.TransactionPayloadEntryFunction(
	Arx.TxnBuilderTypes.EntryFunction.natural(
	    "0x1::subsidialis",
	    "add_coins",
	    [coinType],
	    [Arx.BCS.bcsSerializeUint64(amount)],
	),
    );
    const rawTxn = await client.generateRawTransaction(arxAccount.address(), entryFunctionPayload);
    const bcsTxn = Arx.ArxClient.generateBCSTransaction(arxAccount, rawTxn);
    const transactionResult = await client.submitSignedBCSTransaction(bcsTxn);
    await client.waitForTransaction(transactionResult.hash);
    return transactionResult.hash;
}

// Translate messages.
app.ports.sendCommand.subscribe(async function(cmd) {
    if (cmd.commandType === "fetchAccount") {
	console.log('[port:sendCommand] received fetchAccount');
	const localStorageState = window.localStorage.getItem(ACCOUNT_LOCAL_STORAGE_KEY);
	const account = JSON.parse(localStorageState);
	app.ports.receiveResult.send({"resultType": "fetched", "account": account});
    } else if (cmd.commandType === "generateAccount") { // GenerateAccount -> Account
	console.log('[port:sendCommand] received generateAccount');
	const account = new Arx.ArxAccount();
	const accountObject = account.toPrivateKeyObject();
	window.localStorage.setItem(ACCOUNT_LOCAL_STORAGE_KEY, JSON.stringify(accountObject));
	app.ports.receiveResult.send({"resultType": "account", "account": account});
    } else if (cmd.commandType === "faucetArxCoin") {
	console.log('[port:sendCommand] faucetArxCoin');
	const hashes = await Faucet.fundAccount(cmd.address, cmd.amount);
	app.ports.receiveResult.send({"resultType": "hashes", "hashes": hashes});
    } else if (cmd.commandType === "subsidialisAddCoins") {
	console.log('[port:sendCommand] subsidialis.addCoins(' + cmd.amount + ')');
	const account = Arx.ArxAccount.fromArxAccountObject(cmd.account);
	const hash = await subsidialisAddCoins(account, cmd.amount);
	app.ports.receiveResult.send({"resultType": "txnHash", "hash": hash});
    } else if (cmd.commandType === "subsidialisJoin") {
	console.log('[port:sendCommand] subsidialis.join()');
	const account = Arx.ArxAccount.fromArxAccountObject(cmd.account);
	const hash = await subsidialisJoin(account);
	app.ports.receiveResult.send({"resultType": "txnHash", "hash": hash});
    } else {
	console.log('[port:sendCommand] Invalid command type');
    }
});
