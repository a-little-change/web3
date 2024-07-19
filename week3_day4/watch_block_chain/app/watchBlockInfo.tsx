'use client'
import React from 'react';
import { createPublicClient, parseAbiItem, WatchBlocksReturnType, WatchEventReturnType, webSocket } from "viem";
import { mainnet } from "viem/chains";

const MAINNET_WEBSOCKET = "wss://ethereum-rpc.publicnode.com";
const USDT_ADDR = "0xdac17f958d2ee523a2206206994597c13d831ec7";

const publicClient = createPublicClient({
  chain: mainnet,
  transport: webSocket(MAINNET_WEBSOCKET)
});

let blockInfo: { number: string, hash: string };


let unWatchBlocks: WatchBlocksReturnType;

const watchBlocks = () => {
  unWatchBlocks = publicClient.watchBlocks({
    onBlock: block => {
      console.log(`新区块： ${block.number.toString()} (${block.hash})`);
      blockInfo = {
        number: block.number.toString(),
        hash: block.hash
      };
    }
  })
}

let unwatchEvent: WatchEventReturnType;

let logInfo = {
  blockNumber: "",
  blockHash: "",
  topics: [] as string[],
  data: ""
}

const watchEvent = () => {
  unwatchEvent = publicClient.watchEvent({
    address: USDT_ADDR,
    event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
    onLogs: logs => {
      logs.forEach(log => {
        let amount = parseInt(log.data) / 10 ** 6;
        console.log(`在 ${log.blockNumber.toString()} 区块 ${log.blockHash} 交易中从 ${log.topics[1]} 转账 ${amount} USDT 到${log.topics[2]}`);
        logInfo = {
          blockNumber: log.blockNumber.toString(),
          blockHash: log.blockHash,
          topics: log.topics,
          data: log.data
        };
      });
    }
  });
}


function Watch() {
  return (
    <div>
      <button onClick={watchBlocks}>开始监控</button>
      <button onClick={unWatchBlocks}>停止监控区块</button>
      <button onClick={watchEvent}>开始监控事件</button>
      <button onClick={unwatchEvent}>停止监控事件</button>
      <br />
      {blockInfo && (
        <div>新区块： {blockInfo.number.toString()} ({blockInfo.hash})</div>
      )}
      {/* 在 {logInfo.blockNumber.toString()} 区块 ${logInfo.blockHash} 交易中从 ${logInfo.topics[1]} 转账 ${parseInt(logInfo.data) / 10 ** 6} USDT 到${logInfo.topics[2]} */}
    </div>
  );
}

export default Watch;
