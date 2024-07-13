import { createPublicClient, http } from 'viem'
import { mainnet } from 'viem/chains'

const publicClient = createPublicClient({
    chain: mainnet,
    transport: http()
})

const wagmiAbi = [
    {
        inputs: [{ name: "owner", type: "address" }],
        name: "balanceOf",
        outputs: [{ name: "", type: "uint256" }],
        stateMutability: "view",
        type: "function",
    },

    {
        inputs: [{ name: "tokenId", type: "uint256" }],
        name: "ownerOf",
        outputs: [{ name: "", type: "address" }],
        stateMutability: "view",
        type: "function"
    },
]

export const owner = await publicClient.readContract({
    address: '0x0483b0dfc6c78062b9e999a82ffb795925381415',
    abi: wagmiAbi,
    functionName: 'ownerOf',
    args: [1n]
})
