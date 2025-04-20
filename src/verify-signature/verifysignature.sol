// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract VerifySignature {
    /**
        线下的message也需要先通过keccak256(abi.encodePacked(_message)); 进行hash，再进行签名
     */
    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    /**
        建议使用 abi.encode 防止 hash collision
     */
    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encode(_message));
    }

    /**
         以太坊标准格式要求的特定格式化拼接， 
         keccak256("\x19Ethereum Signed Message:\n" + len(message) + message)
     */
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            _messageHash
        ));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "invaild signature length");
        assembly {
        /*
        First 32 bytes stores the length of the signature

        add(sig, 32) = pointer of sig + 32
        effectively, skips first 32 bytes of signature

        mload(p) loads next 32 bytes starting at the memory address p into memory
        */

        // first 32 bytes, after the length prefix
        r := mload(add(_sig, 32))
        // second 32 bytes
        s := mload(add(_sig, 64))
        // final byte (first byte of the next 32 bytes)
        v := byte(0, mload(add(_sig, 96)))
    }

        // implicitly return (r, s, v)
    }
}
