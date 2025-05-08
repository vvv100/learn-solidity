// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiDelegateCall {

    error DelegatecallFailed();
    error AlreadyDeposited();
    error AlreadyMinted();
    error NothingToClaim();

    struct BatchContext {
        bool deposited;
        bool minted;
    }

    mapping(address => uint) public balanceOf;

    mapping(address => uint) public pendingDeposit;

    mapping(address => BatchContext) internal batchContext;

    function multicall(bytes[] memory _data) external returns (bytes[] memory result) {
        require(_data.length > 0, "empty batch");

        result = new bytes[](_data.length);
        

        for (uint i = 0; i < _data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(_data[i]);
            if (!ok) {
                revert DelegatecallFailed();
            }
            result[i] = res;
        }

        delete batchContext[msg.sender];
    }


}