// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PetNFT is ERC721 {
    uint256 public constant MAX_PETS = 10000; // 总量

    // nounces of accounts
    mapping(address => uint) nounces;

    constructor() ERC721("Pet NFT", "PNFT") {
    }

    // 传入地址
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }

    // 铸造函数
    function mint(address to, uint256 tokenId) external {
        require(tokenId >= 0 && tokenId < MAX_PETS, "tokenId out of range");
        _mint(to, tokenId);
    }
}
