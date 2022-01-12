// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./DapptoolsDemo.sol";

contract DapptoolsDemoTest is DSTest {
    DapptoolsDemo demo;

    function setUp() public {
        demo = new DapptoolsDemo();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
