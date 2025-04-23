// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./IERC721.sol";
import "./Address.sol";

contract ERC721 is IERC721 {
    using Address for address;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(
        address indexed owner,
        address indexed approved,
        uint indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // mapping from tokenId to owner addresss
    mapping(uint => address) private _owners;

    // mapping from owner address to the count of token
    mapping(address => uint) private _balances;

    // mapping from single tokenId to approvaled address 
    mapping(uint => address) private _tokenApprovals;

    // mapping from owner to operator approvals equal to approval operator all token id auth
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function balanceOf(address owner) external view override returns (uint balance) {
        return _balances[owner];
    }

    function ownerOf(uint tokenId) external view override returns (address owner) {
        return _owners[tokenId];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {

    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external override {

    }

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        address owner = _owners[tokenId];
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner or approved");
        _transfer(owner, from, to, tokenId);
    }

    function _transfer(address owner, address from, address to, uint tokenId) private {
        
    }

    function _isApprovedOrOwner(address owner, address spender, uint tokenId) private returns(bool) {
        return (spender == owner ||
                _tokenApprovals[tokenId] == spender ||
                _operatorApprovals[owner][spender]);
    }

    function _approve(address owner, address to, uint tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner or approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function getApproved(uint tokenId) external view override returns (address operator) {
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) external override {
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return 
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}