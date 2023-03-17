// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CDPStakingPool {
    // 奖励的token
    IERC20 public token;
    // 质押的token
    IERC20 public lp;

    // 质押奖励的发放速率
    uint256 public rewardRate = 1 * 10**18;
    // 每次有用户操作时，更新为当前时间
    uint256 public lastUpdateTime;
    // 每单位数量获得奖励的累加值，这里是乘上奖励发放速率后的值
    uint256 public perTokenRewardStored;
    // 开始质押时间
    uint256 public startTime;

    // 在单个用户维度上，记录每个用户的累加值(每次操作更新)
    mapping(address => uint256) public perTokenRewardStoredForUser;
    // 用户到当前时刻已可领取的奖励数量(不包含质押数量)
    mapping(address => uint256) public rewards;

    // 池子中质押总量
    uint256 private _totalSupply;
    // 用户的质押数量
    mapping(address => uint256) private _balances;

    // 质押成功通知
    event Staked(address indexed user, uint256 amount);
    // 提取成功通知
    event Withdrawn(address indexed user, uint256 amount);
    // 获取奖励成功通知
    event GetReward(address indexed user, uint256 amount);

    constructor(address lpToken, address rewardToken) {
        lp = IERC20(lpToken);
        token = IERC20(rewardToken);
        startTime = block.timestamp;
    }

    // 获取当前总质押量
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// 获取当前用户质押量
    function balanceOf(address user) public view returns (uint256) {
        return _balances[user];
    }

    // 获取当前时间
    function getNowTime() public view returns (uint256) {
        return block.timestamp;
    }
    // 获取当前时间每单位数量的累加值,每单位已奖励数量 + (当前时间 - 最后更新时间) * (每秒奖励 / 质押总量)
    function getNowPerTokenReward() public view returns (uint256) {
        if (_totalSupply == 0) {
            return perTokenRewardStored;
        }
        uint256 time = getNowTime() - lastUpdateTime;
        // 每单位在此时间段内获得的奖励数量
        uint256 perTokenReward = time * rewardRate / _totalSupply;
        return perTokenRewardStored + perTokenReward;
    }

    // 获取当前用户总共已赚取的数量,质押数量 * （当前累加值 - 上次操作时的累加值）+ 上次已更新的奖励数量
    function earned(address user) public view returns (uint256) {
        // 用户质押的数量
        uint256 stakingCount = _balances[user];
        // 用户最新赚取的数量 (因为stakingCount数量是带10^18的，所以后面要先乘后除，确保最后数量准确且中间不会产生小数)
        uint256 newEarnCount = stakingCount * (getNowPerTokenReward() - perTokenRewardStoredForUser[user]) / (10**18);
        // 之前已经赚取的数量
        uint256 earnCount = rewards[user];
        return newEarnCount + earnCount;
    }

    // 更新用户的奖励
    modifier updateReward(address user) {
        // 更新累加值
        perTokenRewardStored = getNowPerTokenReward();
        // 记录更新时间
        lastUpdateTime = block.timestamp;
        if (user != address(0)) {
            //更新用户奖励
            rewards[user] = earned(user);
            //更新用户累加值
            perTokenRewardStoredForUser[user] = perTokenRewardStored;
        }
        _;
    }

    // 检查是否已开始质押
    modifier checkStart() {
        require(block.timestamp > startTime, "not start");
        _;
    }

    // 质押代币
    function stake(uint256 amount) public checkStart updateReward(msg.sender) {
        require(amount > 0, "amount need > 0");
        uint256 allowCount = lp.allowance(msg.sender, address(this));
        require(allowCount >= amount, "allowance count not enough");

        _totalSupply += amount;
        _balances[msg.sender] += amount;
        lp.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    // 提取奖励
    function getReward() public checkStart updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        require(reward > 0, "no reward");
        rewards[msg.sender] = 0;
        token.transfer(msg.sender, reward);
        emit GetReward(msg.sender, reward);
    }

    // 提取质押
    function withdrawn(uint256 amount) public checkStart updateReward(msg.sender) {
        require(amount > 0 && amount <= _balances[msg.sender], "amount error");
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        lp.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
}