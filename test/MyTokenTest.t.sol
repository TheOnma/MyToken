// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    DeployMyToken public deployer;

    address john = makeAddr("one");
    address jane = makeAddr("jane");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        vm.prank(msg.sender);
        myToken.transfer(john, STARTING_BALANCE);
    }

    function testJohnBalance() public view {
        assertEq(STARTING_BALANCE, myToken.balanceOf(john));
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;

        // John approves Jane to spend tokens on her behalf
        vm.prank(john);
        myToken.approve(jane, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(jane);
        myToken.transferFrom(john, jane, transferAmount);

        assertEq(myToken.balanceOf(jane), transferAmount);
        assertEq(myToken.balanceOf(john), STARTING_BALANCE - transferAmount);
    }

    // Test transfer between accounts
    function testTransfer() public {
        uint256 transferAmount = 10 ether;

        vm.prank(john);
        myToken.transfer(jane, transferAmount);

        assertEq(myToken.balanceOf(john), STARTING_BALANCE - transferAmount);
        assertEq(myToken.balanceOf(jane), transferAmount);
    }
}
