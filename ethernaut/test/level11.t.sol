// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Elevator, Building} from "../src/level11/Elevator.sol";
import {Attacker} from "../script/level11.s.sol";


contract TestContract is Test {
    Elevator public target;
    Attacker public attacker;

    function setUp() public {
        target = new Elevator();
        attacker = new Attacker(address(target));
    }

    function testFuzz_goTo(uint floor) public {
        assertEq(target.top(), false);

        attacker.attack(floor);

        assertEq(target.top(), true);
    }
}
