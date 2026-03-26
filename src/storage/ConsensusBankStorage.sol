// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ConsensusBankStorage {

    struct Account {
        uint256 balance;
        uint256 lastUpdate;
    } 
    struct Loan {
        uint256 amount;
        uint256 lastUpdate;
    }

    mapping(address => Account ) internal accounts;
    mapping(address => Loan) internal loans;

    uint256 internal constant INTEREST_RATE = 5; // 5% per year
    uint256 internal constant SECONDS_IN_YEAR = 365 days;
    uint256 internal constant LTV = 70; // 70%
    uint256 internal constant LOAN_INTEREST_RATE = 8; // 8% per year 

    bool internal locked; 
}