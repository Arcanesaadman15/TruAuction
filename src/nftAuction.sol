// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title nftAuction
 * @dev A contract for conducting an auction of non-fungible tokens (NFTs) on the Ethereum blockchain.
 */

interface IERC721 {
    function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address, address, uint) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract nftAuction is IERC721Receiver  {
    /**
     * @dev Emitted when the auction starts.
     */
    event Start();

    /**
     * @dev Emitted when the auction ends.
     */
    event End();

    /**
     * @dev Emit bid details if it goes thorough.
     */
    event Bid(address indexed sender, uint amount, uint id);

    /**
     * @dev Struct to keep bid details of an nft.
     */
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

    /**
     * @dev Constructor for the auction contract.
     * @param _nft The address of the NFT contract.
     * @param _paymentReceiver The address of the payment receiver/seller.
     * @param _nftIds An array of NFT IDs to be auctioned.
     * @param _startingBids An array of starting bids for the NFTs.
     */
    constructor(address _owner, address _nft, address _paymentReceiver, uint[] memory _nftIds, uint[] memory _startingBids) {
        owner = _owner;
        nft = IERC721(_nft);
        paymentReceiver = payable(_paymentReceiver);
        nftIds = _nftIds;
        startingBids = _startingBids;
     
    }

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    /**
     * @dev Function for the auction to start.
     */
    function start() public {
        require(!started, "STRTED");
        started = true;
        endTime = block.timestamp + 1 minutes;

        emit Start();
    }

    /**
     * @dev Places a bid on an NFT in the auction.
     * @dev When new highest bidder bids old bidders funds are automatically sent back
        easier for in contract accounting and they can rebid.
     * @param Id The ID of the NFT being bid on.
     */
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
        emit Bid(msg.sender,msg.value,Id);
    }
    /**
     * @dev Function for the auction to end.
     */
    function end() external {
        require(started, "!STRT");
        require(block.timestamp > endTime, "!END");
        require(!ended, "END");

        ended = true;
        emit End();
    }

    function claim(uint Id) external {
        require(ended, "END");
        nft.safeTransferFrom(address(this), bids[Id].highestBidder, Id);
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}