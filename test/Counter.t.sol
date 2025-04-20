// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }

    function test_AbiEncode() public {
        string memory s = "v";
        bytes32 s1 = counter.testAbiencode(s);
        bytes32 s2 = counter.testAbiencode2(s);
        assertEq(s1, s2);
    }
}
