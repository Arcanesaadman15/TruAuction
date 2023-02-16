pragma solidity ^0.8.17;

import { BaseTest } from "./BaseTest.sol";
import { AuctionDeployer } from "../../src/AuctionDeployer.sol";
import { nftAuction } from "../../src/nftAuction.sol";
import { MockERC721 } from "../mocks/MockERC721.sol";

contract BaseSetUpTest is BaseTest {

    AuctionDeployer internal Deployer;
    nftAuction internal NftAuction;
    MockERC721 internal erc721;

    address internal auctionOwner = vm.addr(1);
    address internal seller = vm.addr(2);
    
    address internal bidder1 = vm.addr(3);
    address internal bidder2 = vm.addr(4);
    address internal bidder3 = vm.addr(5);

    function _deployTestContracts() internal {
        vm.prank(auctionOwner);
        Deployer = new AuctionDeployer();
        vm.stopPrank();
        
        erc721 = new MockERC721();

    }

    function _mintNft(address addr, uint tokenId) internal {
        erc721.mintTo(addr, tokenId);
    }
}
