// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "lib/forge-std/src/Test.sol";
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

    function testMultipleUsers() public {
        address user1 = address(1); 
        address user2 = address(2);

        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);

        vm.prank(user1);
        consensusBank.depositEth{value: 1 ether}();

        vm.prank(user2);
        consensusBank.depositEth{value: 1 ether}();

        assertEq(consensusBank.getBalance(user1), 1 ether);
        assertEq(consensusBank.getBalance(user2), 1 ether);
    }

    function testWithdrawFail() public {
        vm.expectRevert("Insufficient balance");
        consensusBank.withdrawEth(1 ether);
    }

    function testReentrancyAttack() public {
        Attacker attacker = new Attacker(address(consensusBank));

        vm.deal(address(attacker), 1 ether);

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();
 
        // If the smart contract is safe, the attack will fail
    }
}
