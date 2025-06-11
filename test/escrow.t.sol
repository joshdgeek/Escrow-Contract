// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RealEstateEscrow} from "../src/escrow.sol";

contract RealEstateEscrowTest is Test {
    RealEstateEscrow public escrow;
    address admin;
    address developer;
    uint256 fundTarget;
    uint256 deadline;

    function setUp() public {
        // Initialize the escrow contract with test parameters
        admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        developer = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        fundTarget = 3 ether;
        deadline = block.timestamp + 10 minutes;

        vm.deal(admin, 10 ether); // Give admin some ether for testing
        vm.startPrank(admin);
        escrow = new RealEstateEscrow(admin, developer, fundTarget, deadline);
        vm.stopPrank();
    }

    function testInitialConditions() public {
        assertEq(escrow.fundTarget(), fundTarget);
        assertEq(escrow.deadline(), deadline);
        assertEq(escrow.totalFunded(), 0);
        assertFalse(escrow.withdrawStatus());
    }

    function testInvestment() public {
        //test deposit
        vm.startPrank(admin);
        escrow.investFunction{value: 3 ether}();
        console.log("Total Funded:", escrow.totalFunded());
        vm.stopPrank();
        assertEq(escrow.totalFunded(), 3 ether); //check totalFunded state
        assertEq(escrow.isInvestor(admin), 3 ether); //verify the amount invested
        assertEq(escrow.remainingAmountToFundTarget(), 0 ether); //verify the remaining amount to hit target
    }

    function testWithdrawal() public {
        vm.startPrank(admin);
        escrow.investFunction{value: 2 ether}(); // admin invest 2 ether
        vm.stopPrank();

        assertEq(admin.balance, 8 ether); // verify the new balance of admin
        assertEq(escrow.totalFunded(), 2 ether); // verify the totalFunded state

        vm.startPrank(admin);
        escrow.withdrawal(); // admin withdraws his funds
        vm.stopPrank();

        assertEq(escrow.totalFunded(), 0 ether); //verify the new state of totalFunded after admin places withdrawal
        assertEq(escrow.isInvestor(admin), 0 ether); //check onchain data of admin after withdraw
        assertEq(admin.balance, 10 ether); // verify the new state of the admin balance
    }

    function testDeveloperWithdrawal() public {
        vm.startPrank(admin);
        escrow.investFunction{value: 3 ether}(); //invest 2 ether
        escrow.releaseToDeveloper(); //release funds to developer
        vm.stopPrank();

        assertEq(developer.balance, 3 ether); //check developer balance before the deadline
    }
}
