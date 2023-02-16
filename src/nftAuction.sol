// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IERC721 {
    function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address, address, uint) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract nftAuction is IERC721Receiver  {
    event Start();
    event End();
    event Bid(address indexed sender, uint amount, uint id);

    struct BidDetails{
        address highestBidder;
        uint highestBid;
    }

    IERC721 public nft;
    address public owner;
    bool public started;
    bool public ended;
    address payable public paymentReceiver;
    uint[] nftIds;
    uint[] startingBids;
    uint public endTime;
    mapping(uint => BidDetails) public bids;


    constructor(address _owner, address _nft, address _paymentReceiver, uint[] memory _nftIds, uint[] memory _startingBids) {
        owner = _owner;
        nft = IERC721(_nft);
        paymentReceiver = payable(_paymentReceiver);
        nftIds = _nftIds;
        startingBids = _startingBids;
     
    }

    function start() external {
        require(!started, "STRTED");
        started = true;
        endTime = block.timestamp + 1 days;

        emit Start();
    }

    function bid(uint Id) external payable {

        require(started, "!STRT");
        require(block.timestamp < endTime, "END");
        require(msg.value > bids[Id].highestBid);
        require(nft.ownerOf(Id) == address(this));

        if (bids[Id].highestBid == 0){
            require(msg.value > startingBids[Id]);
        }

        uint currentBid = bids[Id].highestBid;
        address currentBidder = bids[Id].highestBidder;

        bids[Id].highestBidder = msg.sender;
        bids[Id].highestBid = msg.value;

        payable(currentBidder).transfer(currentBid);
    }

    function end() external {
        require(started, "!STRT");
        require(block.timestamp >= endTime, "!END");
        require(!ended, "END");

        ended = true;
        emit End();
    }

    function claim(uint Id) external {
         nft.safeTransferFrom(address(this), bids[Id].highestBidder, Id);
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}