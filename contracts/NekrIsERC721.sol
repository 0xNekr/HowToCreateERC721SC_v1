//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NekrIsERC721 is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint;

    Counters.Counter private _tokenIds;

    uint public constant MAX_SUPPLY = 100;
    uint public constant PRICE = 0.00001 ether;

    string public baseTokenURI;

    constructor(string memory baseURI) ERC721("Nekr Collection", "NEKR") {
        setBaseURI(baseURI);
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseTokenURI, _tokenId.toString(),".json"));
    }

    function mintNFTs(uint _count) external payable {
        uint totalMinted = _tokenIds.current();

        require(totalMinted + _count <= MAX_SUPPLY, "The total supply has been reached.");
        require(msg.value >= PRICE * _count, "Not enough funds to purchase.");

        for (uint i = 0; i < _count; i++) {
            uint newTokenID = _tokenIds.current();
            _mint(msg.sender, newTokenID);
            _tokenIds.increment();
        }
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

}