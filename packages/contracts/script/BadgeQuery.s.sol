// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {ReputationBadge} from "../src/ReputationBadge.sol";

/// @notice Reads SBT ownership information for a user.
contract BadgeQuery is Script {
    function run() external {
        address badgeAddress = vm.envAddress("BADGE_ADDRESS");
        address user = vm.envAddress("USER_ADDRESS");

        ReputationBadge badge = ReputationBadge(badgeAddress);

        console2.log("== Badge Query ==");
        console2.log("Badge contract:", badgeAddress);
        console2.log("User:", user);

        bool hasAny = badge.balanceOf(user) > 0;
        console2.log("Has badges:", hasAny);
        if (!hasAny) return;

        uint256[] memory ids = badge.badgeIdsOf(user);
        console2.log("Badge count:", ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 badgeId = ids[i];
            uint256 ruleId = badge.badgeRule(badgeId);
            string memory metadataURI = badge.badgeURI(badgeId);
            console2.log(" - badgeId:", badgeId);
            console2.log("   ruleId:", ruleId);
            console2.log("   metadataURI:", metadataURI);
        }
    }
}
