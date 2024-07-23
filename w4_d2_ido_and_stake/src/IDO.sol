// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC2612} from "@openzeppelin/contracts/interfaces/IERC2612.sol";

contract IDO is Ownable {
    uint public totalSale;

    uint public minAmount;

    uint public maxPurchase;

    uint public minRaised;

    uint public maxRaised;

    uint public deadline;

    address public tokenAddr;

    mapping(address => uint) public payments;

    struct SignedData {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    constructor(address owner, address tokenAddr_) Ownable(owner) {
        minAmount = 0.001 ether;
        maxPurchase = 0.02 ether;
        minRaised = 100 ether;
        maxRaised = 200 ether;
        deadline = 30 days;
        tokenAddr = tokenAddr_;
    }

    /**
     * preoder the token
     */
    function presale() public payable {
        if (block.timestamp > deadline) revert ActivityHasEnded();
        if (msg.value < minAmount) revert AmountTooSmall();
        uint payment = payments[msg.sender] + msg.value;
        if (payment >= maxPurchase) revert PaymentTooMuch();
        if (address(this).balance >= maxRaised) revert RaisedIsEnough();
        payments[msg.sender] = payment;
    }

    function claim(SignedData calldata signedToken) public {
        if (block.timestamp < deadline) revert NotClaimingTime();
        if (payments[msg.sender] == 0) revert PaymentIsZero();
        // If is refunded or transfered, clear the payment; prevent reentrant attacks
        payments[msg.sender] = 0;
        // perorder failed, pay back ether
        if (address(this).balance < minRaised) {
            (bool success, ) = msg.sender.call{value: payments[msg.sender]}("");
            if (!success) revert SendFailed(msg.sender, payments[msg.sender]);
        } else {
            address owner = Ownable(tokenAddr).owner();
            uint amount = (totalSale * payments[msg.sender]) / maxRaised;
            // token owner permit
            IERC2612(tokenAddr).permit(
                owner,
                address(this),
                amount,
                deadline,
                signedToken.v,
                signedToken.r,
                signedToken.s
            );
            // preoder succeed, tranfer the tokens
            bool success = IERC20(tokenAddr).transferFrom(
                owner,
                msg.sender,
                amount
            );
            if (!success) revert TransferFailed(owner, msg.sender, amount);
        }
    }

    function withdraw() public {
        payable(owner()).transfer(address(this).balance);
    }

    error AmountTooSmall();

    error PaymentTooMuch();

    error RaisedIsEnough();

    error NotClaimingTime();

    error PaymentIsZero();

    error ActivityHasEnded();

    error SendFailed(address to, uint value);

    error TransferFailed(address from, address to, uint value);
}
