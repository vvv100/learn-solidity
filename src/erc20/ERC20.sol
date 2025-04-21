// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint public totalSupply;

    mapping(address => uint) public balanceOf;

    // your address => approve address => amount
    mapping(address => mapping(address => uint)) public allowance;

    string public name = "vvvToken";

    string public symbol = "vvv";

    uint public decimal = 18;

    function transfer(address recipient, uint amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not Enough Balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // 授权第三方地址，使用一定数量的代币
    function approve(address spender, uint amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not Enough Balance");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // eg: Alice 调用 approve(router, 1000)，授权 Uniswap 的路由合约最多转她 1000 个代币
    // Uniswap 合约随后调用 transferFrom(Alice, ...) 来代 Alice 扣费
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        require(allowance[sender][msg.sender] >= amount, "Not Enough Balance");
        require(balanceOf[sender] >= amount, "Not Enough Balance");

        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external returns (bool) {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        return true;
    }
    
    function burn(uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        return true;
    }
    
}