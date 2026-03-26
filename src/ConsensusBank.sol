// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./core/Lending.sol";

contract ConsensusBank is Lending { 

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    event DepositEth(address indexed user, uint256 amount);
    event WithdrawEth(address indexed user, uint256 amount);


    // ---- ACCOUNT ----

    // Deposit ETH
    function depositEth() external payable {
        require(msg.value > 0, "Must send ETH");

        _updateBalance(msg.sender);

        accounts[msg.sender].balance += msg.value;

        emit DepositEth(msg.sender, msg.value);
    }

    // Withdraw ETH
    function withdrawEth(uint256 amount) external nonReentrant {
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
        Account memory account = accounts[user];

        uint256 timeElapsed = block.timestamp - account.lastUpdate;

        uint256 interest = InterestLib.calculateInterest(account.balance, INTEREST_RATE, timeElapsed, SECONDS_IN_YEAR );

        return account.balance + interest;
    }



    // ---- LOANS ----

    // Borrow
    function borrow(uint256 amount) external nonReentrant {
        _updateBalance(msg.sender);
        _updateLoan(msg.sender);

        uint256 collateral = accounts[msg.sender].balance;
        uint256 maxBorrow = (collateral * LTV) / 100;
 
        require(loans[msg.sender].amount + amount <= maxBorrow, "Exceeds LTV");


        loans[msg.sender].amount += amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // Repay loan
    function repayLoan() external payable nonReentrant {
        require(msg.value > 0, "Must repay something");

        _updateLoan(msg.sender);

        uint256 debt = loans[msg.sender].amount;

        if (msg.value >= debt) {
            loans[msg.sender].amount = 0;
        } else {
            loans[msg.sender].amount -= msg.value; 
        }
    }

    // Check debt
    function getDebt(address user) external view returns (uint256) {
        Loan memory loan = loans[user];

        uint256 timeElapsed = block.timestamp - loan.lastUpdate;

        uint256 interest = InterestLib.calculateInterest(loan.amount, LOAN_INTEREST_RATE, timeElapsed, SECONDS_IN_YEAR);

        return loan.amount + interest;
    }
}