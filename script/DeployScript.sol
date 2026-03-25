// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "lib/forge-std/src/Test.sol";
import "../src/ConsensusBank.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        new ConsensusBank();

        vm.stopBroadcast();
    }
}