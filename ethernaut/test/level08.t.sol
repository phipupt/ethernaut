// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/level08/Vault.sol";

contract TestContract is Test {
    Vault public instance;
    bytes32 pwd = "hello world";

    function setUp() public {
        instance = new Vault(pwd);
    }

    function test_unlock() public {
        bool unlockBefore = instance.locked();

        instance.unlock(pwd);

        bool unlockAfter = instance.locked();

        assertEq(unlockBefore, true);
        assertEq(unlockAfter, false);
    }

    function test_if_unlock_with_other_pwd() public {
        bool unlockBefore = instance.locked();

        instance.unlock(bytes32("wrong password"));

        bool unlockAfter = instance.locked();

        assertEq(unlockBefore, true);
        assertEq(unlockAfter, true);
    }
}
