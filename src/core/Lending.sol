// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./ConsensusBankCore.sol";

contract Lending is ConsensusBankCore {
    
    function _updateLoan(address user) internal {
        Loan storage loan = loans[user];

        uint256 timeElapsed = block.timestamp - loan.lastUpdate;

        uint256 interest = InterestLib.calculateInterest(loan.amount, LOAN_INTEREST_RATE, timeElapsed, SECONDS_IN_YEAR);

        loan.amount += interest;
        loan.lastUpdate = block.timestamp;
    }
} 