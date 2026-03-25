// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/ConsensusBank.sol";

contract ConsensusBankTest is Test {
    ConsensusBank consensusBank;

    function setUp() public {
        consensusBank = new ConsensusBank();
    }

    function testDepositEth() public {
        consensusBank.depositEth{value: 1 ether}();
        assertEq(consensusBank.getBalance(address(this)), 1 ether);
    }

    function testWithdrawEth() public {
        consensusBank.depositEth{value: 1 ether}();
        consensusBank.withdrawEth(0.5 ether);

        assertEq(consensusBank.getBalance(address(this)), 0.5 ether);
    }
}