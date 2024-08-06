// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "./Token.sol";

contract TokenFactoryV1 is Initializable, OwnableUpgradeable {
    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    function deployInscription(
        string memory symbol,
        uint totalSupply,
        uint perMint
    ) public {
        new Token(symbol, symbol, totalSupply, perMint, address(this));
    }

    function mintInscription(address tokenAddr) public {
        Token(tokenAddr).mint(msg.sender);
    }
}
