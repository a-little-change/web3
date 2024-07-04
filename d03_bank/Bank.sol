// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    // 账户余额映射
    mapping(address => uint256) public balances;

    // 存款金额的前 3 名用户
    address[3] public accounts;

    // 管理员
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function deposit() public payable {
        // 将存款余额放入映射
        balances[msg.sender] += msg.value;
        // 重排存款金额的前 3 名用户
        rankAmount(msg.sender, balances[msg.sender]);
    }

    // 管理员取款
    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw!");
        require(
            address(this).balance >= amount,
            "Bank balance is insufficient!"
        );
        owner.transfer(amount);
    }

    // 重排存款金额的前 3 名用户
    function rankAmount(address account, uint256 amount) private {
        // 获取存款金额的排名
        if (amount > balances[accounts[2]]) {
            accounts[2] = account;
            if (amount > balances[accounts[1]]) {
                accounts[2] = accounts[1];
                accounts[1] = account;
                if (amount > balances[accounts[0]]) {
                    accounts[1] = accounts[0];
                    accounts[0] = account;
                }
            }
        }
    }
}
