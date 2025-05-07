
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


contract MultiCall {

    function multiCall(address[] calldata _target, bytes[] calldata _data) external view returns(bytes[] memory) {
        require(_target.length == _data.length, "target length != data length");

        bytes[] memory results = new bytes[](_target.length);
        
        for (uint i = 0; i < _target.length; i++) {
            (bool success, bytes memory result) = _target[i].staticcall(_data[i]);
            require(success, "call failed");

            results[i] = result;
        }
        return results;
    }
}