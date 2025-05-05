// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../erc721/IERC721.sol";

contract EnglishAuction {

    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount);

    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable seller;
    uint public endAt;
    uint public constant DURATION = 60;
    bool public started;
    bool public ended;

    // the highest price bidder cannot withdraw 
    address public highestBidder;
    uint public highestBid;

    // store withdrawable auciton price
    mapping(address => uint) public bids;

    constructor(
        address _nft,
        uint _nftId,
        uint _startingBid
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;
        
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    function start() external {
        require(msg.sender == seller, "not seller");
        require(!started, "started");

        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        endAt = block.timestamp + DURATION;

        emit Start();
    }

    function bid() external payable {
        require(started, "auction is not started");
        require(block.timestamp < endAt, "auction is ended");
        require(msg.value > highestBid, "value < hightest price");

        // store not hightest price to bids
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external payable {
        uint balance = bids[msg.sender];
        bids[msg.sender] = 0;

        payable(msg.sender).transfer(balance);

        emit Withdraw(msg.sender, balance); 
    }

    /**
        转账不要用.transfer，因为 .transfer 会现在2300个gas
        seller.transfer(highestBid); == 
        (bool success, ) = seller.call{value: highestBid, gas: 2300}("");
        require(success, "transfer failed");
     */
    function end() external {
        require(started, "auction is not started");
        require(block.timestamp > endAt, "auction is not ended");
        require(!ended, "auction is ended");

        if (highestBidder == address(0)) {
            // auction fail
            nft.transferFrom(address(this), seller, nftId);
        } else {
            nft.transferFrom(address(this), highestBidder, nftId);
            (bool sent, ) = seller.call{value: highestBid}("");
        }
        ended = true;

        emit End(highestBidder, highestBid);
    }

}