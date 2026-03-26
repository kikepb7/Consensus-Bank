// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library InterestLib {

    function calculateInterest(
        uint256 balance,
        uint256 rate,
        uint256 timeElapsed,
        uint256 year
    ) internal pure returns (uint256) {
        if (balance == 0) return 0;

        return (balance * rate * timeElapsed) / (100 * year);
    }
} 