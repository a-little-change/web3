// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    // accounts => balances mapping
    mapping(address => uint256) public balances;

    address public owner;

    constructor(address owner_) {
        owner = owner_;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit TransferFrom(msg.sender, address(this), msg.value);
    }

    function withdraw(uint256 amount) public {
        address _owner = owner; // gas save
        // only owner can withdraw
        require(msg.sender == _owner, "Not owner");
        require(address(this).balance >= amount, "Insufficient balance");
        // if balance is greater than or equal to amount, transfer half balance to the owner
        (bool success, ) = _owner.call{value: amount / 2}("");
        if (!success) revert TransferFailed(_owner, amount / 2);
        // tranfer event
        emit TransferFrom(address(this), msg.sender, amount / 2);
    }

    error TransferFailed(address to, uint value);

    event TransferFrom(address indexed from, address indexed to, uint value);
}
