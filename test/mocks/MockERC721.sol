// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
    
    constructor() ERC721 ("XYZ", "X") {

    }

    function mintTo(address addr, uint tokenId)public{
        _safeMint(addr,tokenId);

    }

}