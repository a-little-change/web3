import { createPublicClient, http, parseAbiItem } from "viem";
import { mainnet } from "viem/chains";

const CONTRACT_ADDRESS = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

const EVENT_ABI = "event Transfer(address indexed, address indexed, uint256)"

// create public client on Ethereum mainnet
const client = createPublicClient({
  chain: mainnet,
  transport: http(),
})

let blockNumber = await client.getBlockNumber();
let logs = await client.getLogs({
  address: CONTRACT_ADDRESS,
  event: parseAbiItem(EVENT_ABI,),
  fromBlock: blockNumber - 99n,
  toBlock: blockNumber
})

function App() {
  console.log("logs:", logs)
  logs.forEach(log => {
    console.log(`从 ${log.args[0]} 转账给 ${log.args[1]} ${Number(log.args[2]) / (10 ** 8)} USDC, 交易ID：${log.transactionHash}`)
  })
  return (
    <div>
      <ul>
        {logs.map((log, index) => (
          <li key={index}>
            <p>从 ${log.args[0]} 转账给 ${log.args[1]} ${Number(log.args[2]) / (10 ** 8)} USDC, 交易ID：${log.transactionHash}</p>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
