package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strconv"
	"strings"
	"time"
)

type Block struct {
	Index     int
	Timestamp string
	Text      string
	PreHash   string
	Hash      string
	Nonce     string
}

const difficulty = 2

func testPow(oldBlock Block, text string) {
	var newBlock Block
	newBlock.Index = oldBlock.Index + 1
	newBlock.Timestamp = time.Now().String()
	newBlock.Text = text
	newBlock.PreHash = oldBlock.Hash

	for i := 0; ; i++ {
		newBlock.Nonce = fmt.Sprintf("%d", i)
		newBlock.Hash = calculateHash(newBlock)
		if !isDifficultyValid(newBlock.Hash) {
			fmt.Println(newBlock.Index)
			fmt.Println(newBlock.Timestamp)
			fmt.Println(newBlock.Text)
			fmt.Println(newBlock.PreHash)
			fmt.Println(newBlock.Hash)
			fmt.Println(newBlock.Nonce)
			fmt.Println("失败!")
			continue
		} else {
			fmt.Println(newBlock.Index)
			fmt.Println(newBlock.Timestamp)
			fmt.Println(newBlock.Text)
			fmt.Println(newBlock.PreHash)
			fmt.Println(newBlock.Hash)
			fmt.Println(newBlock.Nonce)
			fmt.Println("成功")
			break
		}
	}
}

func isDifficultyValid(hash string) bool {
	prefix := strings.Repeat("0", difficulty)
	return strings.HasPrefix(hash, prefix)
}

func calculateHash(block Block) string {
	record := strconv.Itoa(block.Index) + block.Timestamp + block.Text + block.PreHash + block.Nonce
	hash := sha256.New()
	hash.Write([]byte(record))
	hashed := hash.Sum(nil)
	return hex.EncodeToString(hashed)
}

func main() {
	t := time.Now()
	genesisBlock := Block{}
	genesisBlock = Block{0, t.String(), "", "Hello!", calculateHash(genesisBlock), ""}
	testPow(genesisBlock, "First!")
}
