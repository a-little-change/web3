// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "d04_big_bank/BigBank.sol";

contract Ownable {
    receive() external payable { }

    // 管理员账户取款
    function callWithdraw(address payable counter, uint256 amount) public {
        BigBank(counter).transferOwner(address(this));
        BigBank(counter).withdraw(amount);
    }
}
