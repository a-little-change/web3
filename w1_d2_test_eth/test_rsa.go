package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"fmt"
)

func testRsa(name string) {
	// 生成RSA公私钥对
	privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		fmt.Println("Failed generating private key: ", err)
		return
	}
	publicKey := &privateKey.PublicKey

	// 需要签名的数据
	data := testPow(name, 4)
	fmt.Println(data)

	//
	hash := sha256.New()
	hash.Write([]byte(data))
	hashed := hash.Sum(nil)

	// 签名
	signature := sign(privateKey, hashed)
	fmt.Println(signature)
	// 验签
	verify(publicKey, hashed, signature)
}

func sign(privateKey *rsa.PrivateKey, hashed []byte) []byte {
	signature, err := rsa.SignPKCS1v15(rand.Reader, privateKey, crypto.SHA256, hashed)
	if err != nil {
		fmt.Println("Sign failed:", err)
	}
	return signature
}

func verify(publicKey *rsa.PublicKey, hashed []byte, signature []byte) {
	err := rsa.VerifyPKCS1v15(publicKey, crypto.SHA256, hashed, signature)
	if err != nil {
		fmt.Println("验签失败：", err)
	} else {
		fmt.Println("验签成功！")
	}

}

func main() {
	testPow("Alex", 4)
	testPow("Clark", 5)
	testRsa("Alex")
}
