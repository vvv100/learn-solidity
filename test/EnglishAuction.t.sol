// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// 引入 Foundry 测试库
import "forge-std/Test.sol";
import "../src/english-auction/EnglishAuction.sol";
import "../src/erc721/ERC721.sol";


// 引入被测试的合约
/// @dev 模拟一个简单的 ERC721 NFT 实现，仅满足接口要求，无实际逻辑

/// @dev EnglishAuction 测试合约
contract EnglishAuctionTest is Test {
    EnglishAuction auction;
    ERC721 nft;

    // address payable seller = payable(address(0x1));
    address seller = address(0x1);
    address bidder1 = address(0x2);
    address bidder2 = address(0x3);

    uint nftId = 69;
    uint startingBid = 1 ether;

    function setUp() public {
        nft = new ERC721();

        vm.startPrank(seller);
        auction = new EnglishAuction(address(nft), nftId, startingBid);

        nft.mint(seller, nftId);
        nft.approve(address(auction), nftId);
        vm.stopPrank();
    }

    function test_bidAndWithdraw() public {
        vm.prank(seller);
        auction.start();

        vm.deal(bidder1, 5 ether);

        // bidder1 bid 
        vm.prank(bidder1);
        auction.bid{value: 2 ether}();

        assertEq(auction.highestBid(), 2 ether);
        assertEq(auction.highestBidder(), bidder1);

        // bidder2 bid higher price
        vm.deal(bidder2, 5 ether);
        vm.prank(bidder2);
        auction.bid{value: 3 ether}();

        // test bidder1 refound price

        // test bidder1 withdraw
        uint balBefor = bidder1.balance;
        vm.prank(bidder1);
        auction.withdraw();
        uint balAfter = bidder1.balance;
        assertEq(balAfter - balBefor, 2 ether);

        // time skip 61
        skip(61);

        // test end 

        // vm.expectEmit(true, true, false, true);
        // emit EnglishAuction.End(bidder2, 3 ether);
        
        assertEq(auction.highestBid(), 3 ether);
        assertEq(auction.highestBidder(), bidder2);

        assertEq(address(auction).balance, 3 ether);
        auction.end();
        
        assertTrue(auction.ended());
    }   
}