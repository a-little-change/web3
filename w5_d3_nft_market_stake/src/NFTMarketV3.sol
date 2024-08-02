// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract NFTMarketV3 is EIP712, Ownable {
    bytes32 private constant _LIMIT_ORDER_TYPE_HASH =
        keccak256(
            "LimitOrder(address maker,address nft,uint256 tokenId,address payToken,uint256 price,uint256 deadline)"
        );
    uint public constant DECIMALS = 1 ** 18;
    // total staked ETH
    uint public totalStaked;

    // total interest between two method calls which are "stake" or "unstake"
    uint public totalInterest;

    // the compounded interest rate of stake
    uint public accRate;

    uint public accblockNumber;

    mapping(address => StakedInfo) stakeInfos;

    // create stake info
    struct StakedInfo {
        uint balance;
        uint lastAccRate;
    }

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

    constructor() Ownable(msg.sender) EIP712("NFTMarket", "V3") {
        accRate = DECIMALS;
    }

    function hashStruct(LimitOrder memory order) public view returns (bytes32) {
        return
            EIP712._hashTypedDataV4(
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

    function permitBuyWithETH(
        LimitOrder calldata order,
        SignedData calldata signedOrder
    ) external payable {
        // check whether the order's signer is buyer
        checkLimitOrder(order, signedOrder);
        IERC721 nft = IERC721(order.nft);
        nft.safeTransferFrom(order.maker, msg.sender, order.tokenId);
        // whether the buyer sender engouth ETH
        if (msg.value < order.price)
            revert SendInsufficientETH(msg.sender, msg.value, order.price);
        // charge a 0.3% fee
        uint amount = (order.price * 997) / 1000;
        payable(order.maker).transfer(amount);
        // accumulate total interest
        totalInterest += order.price - amount;
    }

    function stake() external payable {
        // accumulate the rate before update total staked
        _accumulateRate();
        totalStaked += msg.value;
        stakeInfos[msg.sender].balance += msg.value;
        stakeInfos[msg.sender].lastAccRate = accRate;
    }

    function unstake(uint amount) external {
        uint balance = stakeInfos[msg.sender].balance;
        // accumulate the rate before update total staked
        _accumulateRate();
        // caculate the principal and interest sum
        balance *= (accRate / stakeInfos[msg.sender].lastAccRate) / DECIMALS;
        require(balance >= amount, "Unsufficient Balance");
        totalStaked -= (amount - (balance - stakeInfos[msg.sender].balance));
        // caculate the balance
        stakeInfos[msg.sender].balance = balance - amount;
        // update the rate
        stakeInfos[msg.sender].lastAccRate = accRate;
    }

    /**
     * accumulate the compounded interest rate of stake
     */
    function _accumulateRate() private {
        accRate = accRate + (accRate * totalInterest) / totalStaked;
        totalInterest = 0;
    }

    error SendInsufficientETH(address buyer, uint balance, uint price);

    error TransferFailed(address from, address to, uint value);

    error ExpiredSignature(uint256 deadline);

    error InvalidSigner(address signer, address owner);

    error InsufficientBalance(address buyer);
}
