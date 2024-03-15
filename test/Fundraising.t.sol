// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Fundraising.sol";

contract FundraisingTest is Test {
    Fundraising public fundraising;
    address public owner;
    string private title = "Title";

    function setUp() public {
        fundraising = new Fundraising(title);
        owner = msg.sender;
    }

    function test_anyone_can_set_title(address randomAddress) public {
        vm.prank(randomAddress);
        string memory expectedTitle = "newTitle";
        fundraising.setTitle(expectedTitle);
        vm.prank(owner);
        string memory actualTitle = fundraising.getTitle();
        assertEq(expectedTitle, actualTitle);
    }
}
