// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../erc721/IERC721.sol";

contract DutchAuction {

    uint public constant DURATION = 7 days;

    IERC721 public immutable nftAddress;
    uint public immutable nftId;

    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expireAt;
    uint public immutable discountRate;

    constructor(
        uint _startingPrice,
        uint _discountRate,
        address _nftAddress,
        uint _nftId
    ) {
        require(_startingPrice >= _discountRate * DURATION, "starting price < min");
        nftAddress = IERC721(_nftAddress);
        nftId = _nftId;

        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        expireAt = startAt + DURATION;
        discountRate = _discountRate;
    }

    function getPrice() public view returns(uint) {
        return startingPrice - (block.timestamp - startAt) * discountRate;
    }

    function buy() external payable {
        require(block.timestamp < expireAt, "auction is ended");

        uint price = getPrice();
        require(msg.value >= price, "not enough money");

        nftAddress.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0) {
            (bool success, ) = payable(msg.sender).call{value: refund}("");
            require(success, "Refund failed");
        }

        selfdestruct(seller);
    }
    
}