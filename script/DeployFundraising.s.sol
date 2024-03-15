// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {Fundraising} from "../src/Fundraising.sol";

contract DeployFundraising is Script {
    function run() public returns (Fundraising) {
        vm.startBroadcast();
        Fundraising fundraising = new Fundraising("Title");
        vm.stopBroadcast();
        return fundraising;
    }
}
