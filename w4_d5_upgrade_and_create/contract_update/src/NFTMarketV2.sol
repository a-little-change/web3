// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC2612} from "@openzeppelin/contracts/interfaces/IERC2612.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

/// @custom:oz-upgrades-from NFTMarketV1
contract NFTMarketV2 is
    Initializable,
    EIP712Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    // Listed NFT info
    struct ListedNFT {
        address seller;
        uint256 price;
        address payToken;
    }

    // NFT合约地址 => TokenId => 上架的NFT
    mapping(address => mapping(uint256 => ListedNFT)) listedNFTs;

    bytes32 private constant _LIMIT_ORDER_TYPE_HASH =
        keccak256(
            "LimitOrder(address maker,address nft,uint256 tokenId,address payToken,uint256 price,uint256 deadline)"
        );

    struct LimitOrder {
        address maker;
        address nft;
        uint tokenId;
        address payToken;
        uint256 price;
        uint256 deadline;
    }

    struct SignedData {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __EIP712_init("NFTMarketV2", "1");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function hashStruct(LimitOrder memory order) public view returns (bytes32) {
        return
            EIP712Upgradeable._hashTypedDataV4(
                keccak256(
                    abi.encode(
                        _LIMIT_ORDER_TYPE_HASH,
                        order.maker,
                        order.nft,
                        order.tokenId,
                        order.payToken,
                        order.price,
                        order.deadline
                    )
                )
            );
    }

    function checkLimitOrder(
        LimitOrder calldata order,
        SignedData calldata data
    ) public view {
        if (block.timestamp > order.deadline)
            revert ExpiredSignature(order.deadline);
        bytes32 digest = hashStruct(order);
        address signer = ecrecover(digest, data.v, data.r, data.s);
        if (signer != order.maker) revert InvalidSigner(signer, order.maker);
    }

    function permitBuy(
        LimitOrder calldata order,
        SignedData calldata signedOrder,
        uint deadline,
        SignedData calldata signedToken
    ) external payable {
        // check whether the order's signer is buyer
        checkLimitOrder(order, signedOrder);
        IERC721 nft = IERC721(order.nft);
        nft.safeTransferFrom(order.maker, msg.sender, order.tokenId);
        // whether the buyer has engouth balance
        IERC20 token = IERC20(order.payToken);
        if (token.balanceOf(msg.sender) < order.price)
            revert InsufficientBalance(msg.sender);
        // get buyer permit
        IERC2612(order.payToken).permit(
            msg.sender,
            address(this),
            order.price,
            deadline,
            signedToken.v,
            signedToken.r,
            signedToken.s
        );
        // transfer from buyer to seller
        bool res = token.transferFrom(msg.sender, order.maker, order.price);
        if (!res) revert TransferFailed(msg.sender, order.maker, order.price);
        // sell success
        emit NFTSellSuccess(order.nft, order.tokenId, order.maker, msg.sender);
    }

    error TransferFailed(address from, address to, uint value);

    error ExpiredSignature(uint256 deadline);

    error InvalidSigner(address signer, address owner);

    error InsufficientBalance(address buyer);

    // sell success event
    event NFTSellSuccess(
        address indexed nft,
        uint indexed tokenId,
        address indexed seller,
        address buyer
    );

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override {}
}
