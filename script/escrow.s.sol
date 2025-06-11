// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RealEstateEscrow} from "../src/escrow.sol";

contract CounterScript is Script {
    RealEstateEscrow public escrow;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        escrow = new RealEstateEscrow(msg.sender, msg.sender, 3 ether, block.timestamp + 30 days);
        console.log("Escrow contract deployed at:", address(escrow));

        vm.stopBroadcast();
    }
}
