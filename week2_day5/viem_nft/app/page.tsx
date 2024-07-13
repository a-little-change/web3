import { owner, tokenURI } from "./client";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div>
        <label>Owner Address: </label>
        {owner}
      </div>
      <div>
        <label>Token Id: </label>
        {tokenURI}
      </div>
    </main>
  );
}
