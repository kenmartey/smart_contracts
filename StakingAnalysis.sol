//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract StakingRewards {
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    /**
     * @notice
     * Create storage variables to store the last update time, rewardPerTokenStored
     */
    uint public rewardRate = 100;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;
    /**
     * @notice
    * MAPPINGS
    * The mapping we create will actually only hold an Index reference to an Array. This array will hold all our stakeholders.
    */
    mapping(address=>uint) public userRewardPerTokenPaid;
    mapping(address=>uint) public rewards;
    mapping(address=>uint) private _balances;
  

    uint private _totalSupply;
    /**
    * @notice
    * CONSTRUCTOR
    * When deploying the smart contract, it automatically sets the stakingToken and 
        the rewards token to be given to the user. 
    */
    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }
    /**
     * @notice
    * MODIFIER
    * These are modifiers which when applied to the functions, updates the state of the storage
        variables.
    */
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    // Functions

    function rewardPerToken() public view returns(uint) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
    }

    function earned(address account) public view returns(uint) {
        return ((_balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) + rewards[account];
    }

    /**
     * @notice
    * The stake function when called allows the user to set an amount they want to stake, 
    * This amount leaves the users account and added to the total supply.
    * This is when the user starts getting some rewards for leaving their amount in the pool 
        for a certain number of duration.
    * The stake method has a external modifier? That means that this function will be allowed to be called from outside the contract.
    */
    function stake(uint _amount) external updateReward(msg.sender) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @notice
     * withdraw takes in an amount of the stake and will remove tokens from that stake
    */
    function withdraw(uint _amount) external updateReward(msg.sender) {
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;       
        stakingToken.transfer(msg.sender, _amount);
    }

    /**
     * @notice
     * This getReward function when called allows the transfer of 
     rewards to be sent to the person performing the staking. 
     * It has the external modifier visiblity because it can be allowed to be called
        from external smart contracts
    */
    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
    }
}

interface IERC20 {
    function totalSupply() external view returns(uint);
    function balanceOf(address account) external view returns(uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns(uint);
    function approve(address spender, uint amount) external returns(bool);
    function transferFrom(address spender, address recipient, uint amount) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}