// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function testAbiencode(string memory _msg) public pure returns (bytes32) {
        return keccak256(abi.encode(_msg));
    }

    function testAbiencode2(string memory _msg) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_msg));
    }
}
