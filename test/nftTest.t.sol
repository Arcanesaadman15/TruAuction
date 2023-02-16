pragma solidity ^0.8.17;

import { BaseSetUpTest } from "./utils/BaseSetUpTest.sol";
import "../lib/forge-std/src/console.sol";
import { nftAuction } from "../src/nftAuction.sol";

contract nftTest is BaseSetUpTest {

    function setUp() public {
        _deployTestContracts();
    }

    function testNFTName() public {
         assertEq(erc721.symbol(), "X");
    }

    function testCreateAuction() public subtest{
        vm.prank(auctionOwner);
        uint256[] memory _nftIds = new uint256[](5);
        uint256[] memory _startingBids = new uint256[](5);
        address auction = Deployer.createNFTAuction(address(erc721), seller, _nftIds, _startingBids);
        vm.stopPrank();
        assert(auction != address(0));
    }

    function testBidAuction() public subtest{
        vm.prank(auctionOwner);
        uint256[] memory _nftIds = new uint256[](5);
        uint256[] memory _startingBids = new uint256[](5);
        address auction = Deployer.createNFTAuction(address(erc721), seller, _nftIds, _startingBids);
        nftAuction(auction).start();
        vm.stopPrank();

        _mintNft(auction,1);

        vm.prank(bidder1);
        vm.deal(bidder1, 1 ether);
        nftAuction(auction).bid{value: 2000}(1);
    }

    function testSecondBidAuction() public subtest{
        vm.prank(auctionOwner);
        uint256[] memory _nftIds = new uint256[](5);
        uint256[] memory _startingBids = new uint256[](5);
        address auction = Deployer.createNFTAuction(address(erc721), seller, _nftIds, _startingBids);
        nftAuction(auction).start();
        vm.stopPrank();

        _mintNft(auction,1);

        vm.prank(bidder1);
        vm.deal(bidder1, 1 ether);
        nftAuction(auction).bid{value: 2000}(1);

        vm.prank(bidder2);
        vm.deal(bidder2, 1 ether);
        nftAuction(auction).bid{value: 4000}(1);
    }
}