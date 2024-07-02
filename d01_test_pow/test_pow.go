package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/rand"
	"strconv"
	"strings"
	"time"
)

func testPow(name string, difficulty int) {
	for i := 0; ; i++ {
		start := time.Now()
		rand.Seed(time.Now().UnixNano())
		nonce := strconv.Itoa(rand.Int())
		hash := calculateHash(name, nonce)
		if !isDifficultyValid(hash, difficulty) {

			fmt.Println(hash)
			fmt.Println(name)
			fmt.Println(nonce)
			fmt.Println("失败!")
			continue
		} else {
			end := time.Now()

			fmt.Println("消耗时间：" + end.Sub(start).String() + "ms")
			fmt.Println(hash)
			fmt.Println(name)
			fmt.Println(nonce)
			fmt.Println("成功")
			break
		}
	}
}

func isDifficultyValid(hash string, difficulty int) bool {
	prefix := strings.Repeat("0", difficulty)
	return strings.HasPrefix(hash, prefix)
}

func calculateHash(name string, nonce string) string {
	record := name + nonce
	hash := sha256.New()
	hash.Write([]byte(record))
	hashed := hash.Sum(nil)
	return hex.EncodeToString(hashed)
}

func main() {
	testPow("Alex", 4)
	testPow("Clark", 5)
}
