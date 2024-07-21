// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PetToken} from "./PetToken.sol";

contract TokenBank {
    error DepositFailed();
    error WithdrawFailed();

    mapping(address => mapping(address => uint256)) public balancesOfTokens;
    
    event TokensReceived(address indexed from, uint256 value);

    function withdraw(address token, uint256 amount) external {
        require(balancesOfTokens[token][msg.sender] > amount);
        bytes memory methodData = abi.encodeWithSignature(
            "transfer(address,uint256)",
            msg.sender,
            amount
        );
        (bool success, ) = token.call(methodData);
        balancesOfTokens[token][msg.sender] -= amount;
        if (success != true) {
            revert WithdrawFailed();
        }
    }

    /**
     * deposit with EOAs signature
     */
    function permitDeposit(
        address token,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        PetToken(token).permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
        bool success = IERC20(token).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        balancesOfTokens[token][msg.sender] += amount;
        emit TokensReceived(msg.sender, amount);
        if (success != true) {
            revert DepositFailed();
        }
    }
}
