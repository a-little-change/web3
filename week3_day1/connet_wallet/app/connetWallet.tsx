'use client'
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createWeb3Modal, defaultWagmiConfig } from "@web3modal/wagmi";
import { cookieStorage, createStorage, State, WagmiProvider } from "wagmi";
import { mainnet, sepolia } from "viem/chains";
import { ReactNode } from "react";
import { useWeb3Modal } from "@web3modal/wagmi/react";


//1. SetUp QueryClient
const queryClient = new QueryClient

//2.Get projectId from 
const projectId = "aacd73855b077b0913a703b02ae7f914"

if (!projectId) {
  throw new Error("Project Id is not defined!")
}

// Create wagmiConfig
const metadata = {
  name: 'Web3Modal',
  description: 'Web3Modal Example',
  url: 'https://web3modal.com', // origin must match your domain & subdomain
  icons: ['https://avatars.githubusercontent.com/u/37784886']
}


const chains = [mainnet, sepolia] as const
export const config = defaultWagmiConfig({
  chains,
  projectId,
  metadata,
  ssr: true,
  storage: createStorage({
    storage: cookieStorage
  }),
})

// Create modal
createWeb3Modal({
  wagmiConfig: config,
  projectId,
  enableAnalytics: true, // Optional - defaults to your Cloud configuration
  enableOnramp: true // Optional - false as default
})

function Web3ModalProvider({
  children,
  initialState
}: {
  children: ReactNode
  initialState?: State
}) {
  return (
    <WagmiProvider config={config} initialState={initialState}>
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    </WagmiProvider>
  )
}

export default function LoginWithWeb3Modal() {
  return (
    <Web3ModalProvider>
      <w3m-button />
    </Web3ModalProvider>
  );
}
