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
	window.localStorage.setItem(ACCOUNT_LOCAL_STORAGE_KEY, JSON.stringify(account));
	app.ports.receiveResult.send({"resultType": "account", "account": account});
    } else if (cmd.commandType === "faucetArxCoin") {
	console.log('[port:sendCommand] faucetArxCoin');
	const hashes = await Faucet.fundAccount(cmd.address, cmd.amount);
	app.ports.receiveResult.send({"resultType": "hashes", "hashes": hashes});
    } else {
	console.log('[port:sendCommand] Invalid command type');
    }
});
