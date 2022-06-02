// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract CharityDonation{
    string public charityName;
    address public owner;
    uint public targetAmount;

    // Track donations made to Charity
    mapping(address=>uint) public donations;

    // Emit events 
    event DonationEvents(uint _amount, address doner);

    // Total donations made to charity
    uint public totalDonations;

    // Set Charity Name and Target amout when smart contract is being deployed.
    constructor (string memory _charityName, uint _targetAmount){
        charityName =_charityName;
        owner = msg.sender;
        targetAmount = _targetAmount;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Modifier to check if donation target reached.
    modifier checkIfTargetReached() {
        require(totalDonations < targetAmount, "Donation target amount has been reached");
        _;
    }

    // Donate function
    function donate() checkIfTargetReached public payable {
        require(targetAmount > totalDonations, "You are very generous but You can't donate more than the Target Amount!");
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        emit DonationEvents(msg.value, msg.sender);
    }

    // Get donation balance from contract
    function getDonationBalance() public view returns(uint){
        return address(this).balance;
    }

    // Release funds from contract to charity
    function releaseFunds(address payable _to, uint _amount) onlyOwner public payable {
        require(totalDonations > 0, "You don't have enough donations for withdrawal");
        _to.transfer(_amount);
        emit DonationEvents(_amount, _to);

    }
}

