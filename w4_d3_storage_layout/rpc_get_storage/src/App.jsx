import React from "react";
import Web3 from "web3";

const sepolia = "https://ethereum-sepolia-rpc.publicnode.com";

const web3 = new Web3(Web3.givenProvider || sepolia);

const getStorage = async () => {
  const contractAddr = "0x4716Eb7dc4aC71D61Ab958182373966D52E5e90D";
  const solt = "0";
  const res = await web3.eth.getStorageAt(contractAddr, solt);
  console.log(res);
  let length = parseInt(res, 16);
  console.log("length:", length);
  let lockSolt = web3.utils.keccak256(
    "0x0000000000000000000000000000000000000000000000000000000000000000"
  );
  console.log("lockSolt:", lockSolt);
  for (let i = 0; i < length; i++) {
    let userSolt = web3.utils
      .toHex(BigInt(lockSolt) + BigInt(i) * 2n)
      .toString();
    console.log(userSolt);
    let amountSolt = (BigInt(userSolt) + 1n).toString();
    let user = await web3.eth.getStorageAt(contractAddr, userSolt);
    let amount = await web3.eth.getStorageAt(contractAddr, amountSolt);
    console.log("user:", "0x" + user.substring(26));
    console.log("startTime:", web3.utils.toDecimal(user.substring(0,26)));
    console.log("amount:", web3.utils.toBigInt(amount).toString());
  }
};
function App() {
  getStorage();
  return <div className="App"></div>;
}

export default App;
