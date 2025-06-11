// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract RealEstateEscrow {
    address admin;
    address developer;

    //define variables
    mapping(address => uint256) public isInvestor;
    uint256 public fundTarget;
    uint256 public totalFunded; //ETH
    uint256 public timeStart = block.timestamp;
    uint256 public deadline = timeStart + 2 minutes;
    bool public withdrawStatus = false;

    event paymentRecieved(
        address indexed investorAddress,
        uint256 amountDeposited,
        bool status
    );
    event withdrawFunds(
        address indexed investorAddress,
        uint256 amountWithdrawn,
        bool status
    );
    event successfullFunding(uint amuntFunded, bool fundStatus);

    constructor(
        address _admin,
        address _developer,
        uint256 _fundTarget,
        uint256 _deadline
    ) {
        admin = _admin; //only admin access,
        developer = _developer; //developer address
        fundTarget = _fundTarget; //SET FUND TARGET
        deadline = _deadline; //SET DEADLINE
    }

    function getCurrent() external view returns (uint256, uint256) {
        return (block.timestamp, deadline);
    }

    //release funds to developers
    function releaseToDeveloper() public onlyAdmin {
        require(!withdrawStatus, "funds withdrawn");
        require(totalFunded >= fundTarget, "Cannot release yet");
        withdrawStatus = true;
        totalFunded -= fundTarget;
        (bool success, ) = payable(developer).call{value: fundTarget}("");
        require(success, "transfer failed");
        emit successfullFunding(fundTarget, true);
    }

    function remainingAmountToFundTarget() public view returns (uint256) {
        return (fundTarget - totalFunded);
    }

    function investFunction() external payable {
        uint256 amount = msg.value;
        require(block.timestamp <= deadline, "Funding period over");

        uint256 allowed = remainingAmountToFundTarget();
        require(amount <= allowed, "Too much");

        isInvestor[msg.sender] += amount;
        totalFunded += amount;
        emit paymentRecieved(msg.sender, amount, true);
    }

    function withdrawal() public {
        uint256 amountAllowedToWithdraw = isInvestor[msg.sender];
        require(totalFunded < fundTarget, "Target reached - cannot withdraw");

        isInvestor[msg.sender] -= amountAllowedToWithdraw;
        totalFunded -= amountAllowedToWithdraw;

        (bool success, ) = payable(msg.sender).call{
            value: amountAllowedToWithdraw
        }("");
        require(success, "transfer failed");
        emit withdrawFunds(msg.sender, amountAllowedToWithdraw, true);
    }

    //Admin only modifier

    //Admin only modifier
    modifier onlyAdmin() {
        require(msg.sender == admin, "unauthorized access");
        _;
    }
}
