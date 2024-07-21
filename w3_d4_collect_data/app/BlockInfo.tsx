'use client'
import React, { Component } from 'react'
import { createPublicClient, parseAbiItem, WatchBlocksReturnType, WatchEventReturnType, webSocket } from "viem";
import { mainnet } from "viem/chains";


const MAINNET_WEBSOCKET = "wss://ethereum-rpc.publicnode.com";
const USDT_ADDR = "0xdac17f958d2ee523a2206206994597c13d831ec7";

export default class BlockInfo extends Component {


    publicClient = createPublicClient({
        chain: mainnet,
        transport: webSocket(MAINNET_WEBSOCKET)
    });

    state = {
        blockInfo: { number: '', hash: '' },
        logsInfo: Array<any>()
    };


    unWatchBlocks: WatchBlocksReturnType | undefined;

    watchBlocks = () => {
        this.unWatchBlocks = this.publicClient.watchBlocks({
            onBlock: block => {
                console.log(`新区块： ${block.number.toString()} (${block.hash})`);
                this.setState({
                    blockInfo: {
                        number: block.number.toString(),
                        hash: block.hash
                    }
                });
            }
        });
    }

    unwatchEvent: WatchEventReturnType | undefined;

    watchEvent = () => {
        let formattedLogs: Array<any> = [];
        this.unwatchEvent = this.publicClient.watchEvent({
            address: USDT_ADDR,
            event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
            onLogs: logs => {
                console.log("logs:",logs.length);
                logs.map(log => (formattedLogs.push({
                    blockNumber: log.blockNumber.toString(),
                    blockHash: log.blockHash,
                    topics: log.topics,
                    data: log.data
                })));
                this.setState({
                    logsInfo: formattedLogs
                });
            }
        });

    }


    render() {
        const { blockInfo, logsInfo } = this.state;
        return (
            <div>
                <button onClick={this.watchBlocks}>开始监控区块</button>
                <button onClick={this.unWatchBlocks}>停止监控区块</button>
                <br />
                {blockInfo.number && (
                    <div>新区块： {blockInfo.number.toString()} ({blockInfo.hash})</div>
                )}
                <br />
                <button onClick={this.watchEvent}>开始监控事件</button>
                <button onClick={this.unwatchEvent}>停止监控事件</button>
                <ul>
                    {logsInfo.length > 0 && logsInfo.map((log, index) => (
                        <li key={index}>
                            在 {log.blockNumber} 区块 {log.blockHash} 交易中从 {log.topics[1]} 转账 {log.amount} USDT 到 {log.topics[2]}
                        </li>
                    ))}
                </ul>

            </div>
        )
    }
}
