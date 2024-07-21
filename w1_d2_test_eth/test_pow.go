package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strings"
	"time"
)

func testPow(name string, difficulty int) string {
	for i := 0; ; i++ {
		start := time.Now()
		nonce := fmt.Sprintf("%d", i)
		hash := calculateHash(name, nonce)
		if !isDifficultyValid(hash, difficulty) {
			continue
		} else {
			end := time.Now()
			fmt.Printf("消耗时间：%d ms\n", end.Sub(start).Milliseconds())
			fmt.Println(hash)
			fmt.Println(name)
			fmt.Println(nonce)
			fmt.Println("成功")
			return hash
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
