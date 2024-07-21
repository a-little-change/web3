// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenBank {
    error DepositFailed();
    error WithdrawFailed();

    mapping(address => mapping(address => uint256)) public balancesOfTokens;

    event Response(bool success, bytes data);

    function deposit(address token, uint256 amount) external {
        bytes memory methodData = abi.encodeWithSignature(
            "transferFrom(address,address,uint256)",
            msg.sender,
            address(this),
            amount
        );
        (bool success, bytes memory data) = token.call(methodData);
        balancesOfTokens[token][msg.sender] += amount;
        emit Response(success, data);
        if (success != true) {
            revert DepositFailed();
        }
    }

    function withdraw(address token, uint256 amount) external {
        require(balancesOfTokens[token][msg.sender] > amount);
        bytes memory methodData = abi.encodeWithSignature(
            "transfer(address,uint256)",
            msg.sender,
            amount
        );
        (bool success, bytes memory data) = token.call(methodData);
        balancesOfTokens[token][msg.sender] -= amount;
        emit Response(success, data);
        if (success != true) {
            revert WithdrawFailed();
        }
    }
}
