// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract MultisigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event ExecuteTransaction(address indexed to, uint value, bytes data);

    address[] public owners;

    mapping(address => bool) isOwner;

    // The minimum number of owners who is signed
    uint256 public threshold;

    uint256 private signerCount;

    mapping(address => uint) private nonces;

    uint256 private nonce = 1;

    // modifier onlyOwner() {
    //     bool isOwner = false;
    //     for (uint i = 0; i < owners.length; i++) {
    //         if (msg.sender == owners[i]) {
    //             isOwner = true;
    //             break;
    //         }
    //     }
    //     require(isOwner, "Not an owner");
    //     _;
    // }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an Owner");
        _;
    }

    constructor(address[] memory owners_, uint256 threshold_) {
        require(owners_.length > 1, "NOt enough Owners");
        require(
            threshold_ > 0 && threshold_ <= owners_.length,
            "Threshold isn't right"
        );
        // Determine whether each owner's respective address is correct
        for (uint i = 0; i < owners_.length; i++) {
            address owner = owners_[i];
            require(
                owner != address(0) &&
                    owner != address(this) &&
                    !isOwner[owner],
                "Have a wrong owner"
            );
            owners.push(owner);
            isOwner[owner] = true;
        }
        threshold = threshold_;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function confrim() public onlyOwner {
        require(nonces[msg.sender] != nonce, "You have signed");
        signerCount++;
        nonces[msg.sender] = nonce;
    }

    function executeTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        require(signerCount >= threshold, "Not enough signer");
        nonce++;
        // safe transfer
        (bool success, ) = _to.call{value: _value}(_data);
        require(success, "tx failed");
        emit ExecuteTransaction(_to, _value, _data);
    }
}
