// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../storage/ConsensusBankStorage.sol";
import "../libraries/InterestLib.sol";

contract ConsensusBankCore is ConsensusBankStorage {
    
    using InterestLib for uint256;

    function _updateBalance(address user) internal {
        Account storage account = accounts[user];

        uint256 timeElapsed = block.timestamp - account.lastUpdate;

        uint256 interest = InterestLib.calculateInterest(account.balance, INTEREST_RATE, timeElapsed, SECONDS_IN_YEAR);

        account.balance += interest;
        account.lastUpdate = block.timestamp;
    }
} 