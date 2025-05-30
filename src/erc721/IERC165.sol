// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}