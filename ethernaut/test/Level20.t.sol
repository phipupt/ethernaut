// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Denial} from "../src/Level20.sol";
import {Attacker} from "../script/Level20.s.sol";

contract TestContract is Test {
    Denial public level;
    Attacker public attacker;

    function setUp() public {
        level = new Denial();
        attacker = new Attacker();
    }

    function testFail_withdraw() public {
        uint amount = 1 ether;
        vm.deal(address(level), amount);

        address partner = address(attacker);

        level.setWithdrawPartner(partner);

        level.withdraw();

        // uint withdrawAmount = amount / 100;

        // assertEq(partner.balance, withdrawAmount);
        // assertEq(level.owner().balance, withdrawAmount);
    }
}
