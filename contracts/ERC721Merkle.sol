// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ERC721Merkle is ERC721 {
    
    bytes32 immutable public root; //merkle tree root 
    uint tokenId = 1;

    constructor(string memory name, string memory symbol, bytes32 merkleroot) 
    ERC721(name, symbol) {
        root = merkleroot;
    }

    function getPrice() public view returns(uint){
        uint _price = 0.3 ether;
        return _price;
    }

    function isWhiteListed(address account, bytes32[] calldata proof) internal view returns(bool){
        return _verify(_leaf(account), proof);
    }

    //to mint an NFT
    function mintNFT(address account, bytes32[] calldata proof) external payable {
        uint price = getPrice();
        require(isWhiteListed(account, proof), "Not on the whitelist");
        require(msg.value >= price, "Not enough funds");
        _safeMint(account, tokenId, "");
        tokenId++;
    }

    //return the address hashed
    function _leaf(address account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(account));
    }

    //verify if the address is in the whitelist
    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns(bool){
        return MerkleProof.verify(proof, root, leaf);
    }
}
