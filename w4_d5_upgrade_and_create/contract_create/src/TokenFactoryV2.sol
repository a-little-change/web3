// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "./PetToken.sol";

contract TokenFactoryV1 is Initializable, OwnableUpgradeable {
    mapping(address => uint) public prices;

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    function deployInscription(
        string memory symbol,
        uint totalSupply,
        uint perMint,
        uint price
    ) public {
        new PetToken(symbol, symbol, totalSupply, perMint, address(this));
        prices[msg.sender] = price;
    }

    function mintInscription(address tokenAddr) public payable {
        require(msg.value >= prices[msg.sender], "Payment isn't Enough!");
        PetToken(tokenAddr).mint(msg.sender);
    }
}
