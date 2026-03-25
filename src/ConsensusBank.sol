// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ConsensusBank {
    mapping(address => uint256) private balances;

    // Deposit ETH
    function depositEth() external payable {
        require(msg.value > 0, "Must send ETH");

        balances[msg.sender] += msg.value;
    }

    // Withdraw ETH
    function withdrawEth(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Effects
        balances[msg.sender] -= amount;

        // Interaction
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // Check balance
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
} 