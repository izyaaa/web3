// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public itemName;
    uint public highestBid;
    address payable public highestBidder;
    mapping(address => uint) public bids;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(
        string memory _itemName,
        uint _startBlock,
        uint _endBlock,
        uint _startingBid
    ) {
        owner = payable(msg.sender);
        itemName = _itemName;
        startBlock = _startBlock;
        endBlock = _endBlock;
        highestBid = _startingBid;
    }

    function bid() public payable {
        require(block.number >= startBlock && block.number < endBlock, "Auction is not active.");
        require(msg.value > highestBid, "Bid must be higher than highest bid.");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = payable(msg.sender);

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public {
        require(bids[msg.sender] > 0, "You have no funds to withdraw.");
        uint amount = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function endAuction() public {
        require(block.number >= endBlock, "Auction has not ended yet.");
        require(msg.sender == owner, "Only the owner can end the auction.");

        if (highestBidder != address(0)) {
            owner.transfer(highestBid);
            emit AuctionEnded(highestBidder, highestBid);
        } else {
            emit AuctionEnded(address(0), 0);
        }
    }
}
