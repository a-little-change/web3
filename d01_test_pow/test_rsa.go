package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
)

func testRsa(name string) {
	privateKey, err := rsa.GenerateKey(rand.Reader, 1024)
	if err != nil {
		panic(err)
	}
	publicKey := privateKey.PublicKey
	hash := testPow(name, 4)
	fmt.Println(hash)
	signData := sign(hash, privateKey)
	fmt.Println(signData)
	fmt.Println(verify(signData, publicKey))
}

func sign(originalData string, privateKey *rsa.PrivateKey) string {
	hash := sha256.New()
	hash.Write([]byte(originalData))
	signature, err := rsa.SignPKCS1v15(rand.Reader, privateKey, crypto.SHA256, hash.Sum(nil))
	if err != nil {
		panic(err)
	}
	return base64.StdEncoding.EncodeToString(signature)
}

func verify(signData string, publicKey rsa.PublicKey) error {
	hash := sha256.New()
	hash.Write([]byte(signData))
	return rsa.VerifyPKCS1v15(&publicKey, crypto.SHA256, hash.Sum(nil), []byte(signData))
}

func main() {
	testPow("Alex", 4)
	testPow("Clark", 5)
	testRsa("Alex")
}
