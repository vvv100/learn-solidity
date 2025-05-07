
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract TestCall {

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
}