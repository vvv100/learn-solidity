
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./MultiDelegateCall.sol";

contract TestCall is MultiDelegateCall {

    function fun1(uint _i) external pure returns(uint) {
        return _i + 1;
    }

    
    function fun2(uint _i) external pure returns(uint) {
        return _i + 2;
    }

    function getFun1Data(uint _i) external returns(bytes memory) {
        return abi.encodeWithSelector(this.fun1.selector, _i);
    }   

    function getFun2Data(uint _i) external returns(bytes memory) {
        return abi.encodeWithSelector(this.fun2.selector, _i);
    } 

    function deposit() external payable {
        BatchContext storage batchContext = batchContext[msg.sender];
        if (batchContext.deposited) {
            revert AlreadyDeposited();
        }
        batchContext.deposited = true;
        
        pendingDeposit[msg.sender] += msg.value;

    }

    function mint(uint amount) external {
        BatchContext storage batchContext = batchContext[msg.sender];
        if (batchContext.minted) {
            revert AlreadyMinted();
        }
        batchContext.minted = true;

        require(pendingDeposit[msg.sender] >= amount, "Insufficient deposit");
        pendingDeposit[msg.sender] -= amount;
        balanceOf[msg.sender] += amount;
    }

    function claim() external {
        uint amount = balanceOf[msg.sender];
        if (amount == 0) {
            revert NothingToClaim();
        }
        // 重置
        balanceOf[msg.sender] = 0;

        // 实际上应该mint NFT，或者发ERC20 token
        // 这里只是示意
    }


}