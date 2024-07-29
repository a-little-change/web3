// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

contract NFTMarketV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    // Listed NFT info
    struct ListedNFT {
        address seller;
        uint256 price;
        address payToken;
    }

    // NFT合约地址 => TokenId => 上架的NFT
    mapping(address => mapping(uint256 => ListedNFT)) listedNFTs;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function list(
        address nftAddr,
        uint256 tokenId,
        address payToken,
        uint256 price
    ) external {
        require(
            IERC721(nftAddr).ownerOf(tokenId) == msg.sender,
            "You are not the Owner!"
        );
        listedNFTs[nftAddr][tokenId] = ListedNFT({
            seller: msg.sender,
            price: price,
            payToken: payToken
        });
    }

    function buyNFT(address nftAddr, uint256 tokenId) external {
        IERC721 nft = IERC721(nftAddr);
        ListedNFT memory listedNFT = listedNFTs[nftAddr][tokenId];
        // 判断该NFT是否上架
        require(listedNFT.seller != address(0), "This nft isn't for sale");
        // 判断余额是否充足
        IERC20 token = IERC20(listedNFT.payToken);
        require(
            token.balanceOf(msg.sender) >= listedNFT.price,
            "You balance isn't enough"
        );
        // delete the listed nft info before, prevent the reentrancy attack
        delete listedNFTs[nftAddr][tokenId];
        bool success = token.transferFrom(
            msg.sender,
            listedNFT.seller,
            listedNFT.price
        );
        if (!success)
            revert TransferFailed(
                msg.sender,
                listedNFT.seller,
                listedNFT.price
            );
        nft.safeTransferFrom(listedNFT.seller, msg.sender, tokenId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override {}
}

error TransferFailed(address from, address to, uint value);
