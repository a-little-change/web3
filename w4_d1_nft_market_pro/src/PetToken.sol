// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PetToken is ERC20 {
    // nounces of accounts
    mapping(address => uint) nounces;

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    bytes32 private constant EIP71DOMIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes32 private immutable DOMAIN_SEPARATOR;

    error ERC2612ExpiredSignature(uint256 deadline);

    error ERC2612InvalidSigner(address signer, address owner);

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    constructor() ERC20("Pet Token", "Pet") {
        _mint(msg.sender, 10 ** 9);
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP71DOMIN_TYPEHASH,
                bytes("Pet"),
                bytes("1"),
                block.chainid,
                address(this)
            )
        );
    }

    function getTypedDataHash(
        Permit memory _permit
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    hex"1901",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            _permit.owner,
                            _permit.spender,
                            _permit.value,
                            _permit.nonce,
                            _permit.deadline
                        )
                    )
                )
            );
    }
    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nounces[owner]++,
                        deadline
                    )
                )
            )
        );
        _approve(owner, spender, value);
        //
        if (ecrecover(digest, v, r, s) != owner) {
            revert ERC2612InvalidSigner(ecrecover(digest, v, r, s), owner);
        }
    }
}
