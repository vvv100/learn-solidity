// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../erc20/IERC20.sol";

contract CrowdFund {

    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed  id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint indexed _id);
    event Refund(uint indexed _id, address indexed caller, uint amount);

    struct Campaign {
        address creator;
        // amount of tokens to raise
        uint goal;
        // Total amount pledged
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 public immutable token;

    uint public count;

    mapping(uint => Campaign) campaigns;

    mapping(uint => mapping(address => uint)) public pledgedAmount;

    modifier inFund(uint _id){
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "before start");
        require(block.timestamp <= campaign.endAt, "after end");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch(
        uint _goal,
        uint32 _startAt,
        uint32 _endAt
    ) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end after start");
        require(_endAt <= _startAt + 90 days, "exceeds 1 month");

        count++;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0, 
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp < campaign.startAt, "started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external inFund(_id) {
        require(token.balanceOf(msg.sender) >= _amount, "not enough balances");

        Campaign storage campaign = campaigns[_id];
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint _id) external inFund(_id) {
        uint amount = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;

        Campaign storage campaign = campaigns[_id];
        campaign.pledged -= amount;
        token.transfer(msg.sender, amount);
        
        emit Unpledge(_id, msg.sender, amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(!campaign.claimed, "is claimed");
        require(campaign.creator == msg.sender, "not creator");
        require(campaign.pledged >= campaign.goal, "pledged <= goal");
        require(block.timestamp > campaign.endAt, "not ended");

        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);

        emit Claim(_id);
    }

    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledged > goal");

        uint balance = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        campaign.pledged -= balance;
        token.transfer(msg.sender, balance);

        emit Refund(_id, msg.sender, balance);
    }
}