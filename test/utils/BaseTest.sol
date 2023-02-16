pragma solidity ^0.8.17;

import { Test } from "../../lib/forge-std/src/Test.sol";

contract BaseTest is Test {

    modifier subtest() {
        uint256 snapshot = vm.snapshot();
        _;
        vm.revertTo(snapshot);
    }

}