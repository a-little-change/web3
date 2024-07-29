// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC2612} from "@openzeppelin/contracts/interfaces/IERC2612.sol";

contract IDO is Ownable {
    uint public constant totalSale = 1e6 ether;

    uint public constant minAmount = 0.001 ether;

    uint public constant maxPurchase = 0.02 ether;

    uint public constant minRaised = 100 ether;

    uint public constant maxRaised = 200 ether;

    uint public immutable deadline = block.timestamp + 30 days;

    uint public totalRaised;

    address public immutable tokenAddr;

    mapping(address => uint) public payments;

    constructor(address owner, address tokenAddr_) Ownable(owner) {
        tokenAddr = tokenAddr_;
    }

    /**
     * preoder 1e6 tokens
     */
    function presale() public payable {
        if (block.timestamp > deadline) revert ActivityIsEnded();
        if (msg.value < minAmount) revert AmountTooSmall();
        uint payment = payments[msg.sender] + msg.value;
        if (payment >= maxPurchase) revert PaymentTooMuch();
        if (address(this).balance >= maxRaised) revert RaisedIsEnough();
        totalRaised += msg.value;
        payments[msg.sender] = payment;
    }

    function claim() public {
        if (block.timestamp < deadline) revert NotClaimingTime();
        if (payments[msg.sender] == 0) revert PaymentIsZero();
        // If is refunded or transfered, clear the payment; prevent reentrant attacks
        payments[msg.sender] = 0;
        // perorder failed, pay back ether
        if (address(this).balance < minRaised) {
            (bool success, ) = msg.sender.call{value: payments[msg.sender]}("");
            if (!success) revert SendFailed(msg.sender, payments[msg.sender]);
        } else {
            address tokenOwner = Ownable(tokenAddr).owner();
            uint amount = (totalSale * payments[msg.sender]) / totalRaised;
            // preoder succeed, tranfer the tokens
            bool success = IERC20(tokenAddr).transferFrom(tokenOwner, msg.sender, amount);
            if (!success) revert TransferFailed(tokenOwner, msg.sender, amount);
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

    error ActivityIsEnded();

    error SendFailed(address to, uint value);

    error TransferFailed(address from, address to, uint value);
}
