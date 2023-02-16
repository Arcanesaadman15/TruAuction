// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {nftAuction} from "./nftAuction.sol";

contract AuctionDeployer {
    event NftAuctionCreated(address indexed sender, uint amount, uint id);
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    function createNFTAuction(
        address _nft,
        address _paymentReceiver,
        uint[] memory _nftIds,
        uint[] memory _startingBids
        ) public onlyOwner returns (address){

        nftAuction auction = new nftAuction(owner,_nft, _paymentReceiver, _nftIds, _startingBids);

        return address(auction);   
    }
}