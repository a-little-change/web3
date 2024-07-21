// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "d06_ERC/TokenRecipient.sol";

contract ExtTokenBank is TokenRecipient {
    error DepositFailed();
    error WithdrawFailed();

    mapping(address => mapping(address => uint256)) public balancesOfTokens;

    event Response(bool success, bytes data);
    event TokensReceived(address from, uint256 value);

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

    function tokensReceived(address from, uint256 value)
        external
        returns (bool)
    {
        balancesOfTokens[msg.sender][from] += value;
        emit TokensReceived(from, value);
        return true;
    }
}
