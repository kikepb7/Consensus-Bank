// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ConsensusBank {
    mapping(address => uint256) private balances;

    bool private locked;

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    event DepositEth(address indexed user, uint256 amount);
    event WithdrawEth(address indexed user, uint256 amount);

    // Deposit ETH
    function depositEth() external payable {
        require(msg.value > 0, "Must send ETH");

        balances[msg.sender] += msg.value;

        emit DepositEth(msg.sender, msg.value);  
    }

    // Withdraw ETH
    function withdrawEth(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Effects
        balances[msg.sender] -= amount;

        // Interaction
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit WithdrawEth(msg.sender, amount); 
    }

    // Check balance
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
} 