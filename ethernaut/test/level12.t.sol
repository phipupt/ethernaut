// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Privacy} from "../src/level12/Privacy.sol";

contract TestContract is Test {
    Privacy public level;
    bytes32[3] private data = [
        bytes32("alice"),
        bytes32("bob"),
        bytes32("casy")
    ];

    function setUp() public {
        level = new Privacy(data);
    }

    function test_unlock(uint floor) public {
        assertEq(level.locked(), true);

        uint levelDataSlotStartIdx = 3;
        bytes32 dataInPos2 = vm.load(
            address(level),
            bytes32(uint256(levelDataSlotStartIdx + 2))
        );

        assertEq(dataInPos2, data[2]);

        bytes16 _key = bytes16(dataInPos2);

        level.unlock(_key);

        assertEq(level.locked(), false);
    }
}
