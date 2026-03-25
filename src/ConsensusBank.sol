// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ConsensusBank { 

    struct Account {
        uint256 balance;
        uint256 lastUpdate;
    }

    mapping(address => Account ) private accounts;

    uint256 public constant INTEREST_RATE = 5; // 5% per year
    uint256 public constant SECONDS_IN_YEAR = 365 days;

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

        _updateBalance(msg.sender);

        accounts[msg.sender].balance += msg.value;
        accounts[msg.sender].lastUpdate = block.timestamp;

        emit DepositEth(msg.sender, msg.value);
    }

    // Withdraw ETH
    function withdrawEth(uint256 amount) external {
        _updateBalance(msg.sender);

        require(accounts[msg.sender].balance >= amount, "Insufficient balance");

        // Effects
        accounts[msg.sender].balance -= amount;

        // Interaction
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit WithdrawEth(msg.sender, amount); 
    }

    // Check balance
    function getBalance(address user) external view returns (uint256) {
        Account memory acc = accounts[user];

        uint256 interest = _calculateInterest(user);

        return acc.balance + interest;
    }

    // Calculate acumulate interest
    function _calculateInterest(address user) internal view returns (uint256) {
        Account memory acc = accounts[user];

        if (acc.balance == 0) return 0;

        uint256 timeElapsed = block.timestamp - acc.lastUpdate;

        uint256 interest = (acc.balance * INTEREST_RATE * timeElapsed) / (100 * SECONDS_IN_YEAR);

        return interest;
    }

    // Update balance with interest
    function _updateBalance(address user) internal {
        uint256 interest = _calculateInterest(user);

        accounts[user].balance += interest;
        accounts[user].lastUpdate = block.timestamp;
    }
}  