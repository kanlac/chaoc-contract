// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {Marketplace} from "../src/Marketplace.sol";
import {ReputationBadge} from "../src/ReputationBadge.sol";
import {BadgeRuleRegistry} from "../src/BadgeRuleRegistry.sol";

/// @notice Reads SBT ownership information and aggregated marketplace stats for a user.
contract BadgeQuery is Script {
    function run() external {
        address marketplaceAddr = vm.envAddress("MARKETPLACE_ADDRESS");
        address user = vm.envAddress("USER_ADDRESS");

        Marketplace marketplace = Marketplace(marketplaceAddr);
        ReputationBadge badge = marketplace.reputationBadge();

        console2.log("== Badge & Transaction Query ==");
        console2.log("Marketplace:", marketplaceAddr);
        console2.log("Badge contract:", address(badge));
        console2.log("User:", user);

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

        Marketplace.BuyerStat memory buyerStat = marketplace.getBuyerStat(user);
        Marketplace.CreatorStat memory creatorStat = marketplace.getCreatorStat(user);

        console2.log("== Marketplace Aggregates ==");
        console2.log("Buyer total purchases:", buyerStat.totalPurchases);
        console2.log("Buyer total volume:", buyerStat.totalVolume);
        console2.log("Creator total sales:", creatorStat.totalSales);
        console2.log("Creator total volume:", creatorStat.totalVolume);

        BadgeRuleRegistry registry = marketplace.badgeRuleRegistry();
        uint256 ruleCount = registry.ruleCount();
        console2.log("== Buyer Badge Coverage ==");
        for (uint256 i = 0; i < ruleCount; i++) {
            uint256 ruleId = registry.ruleIdAt(i);
            BadgeRuleRegistry.BadgeRule memory rule = registry.getRule(ruleId);
            bool hasRule = badge.hasBadge(user, ruleId);
            console2.log(" - ruleId:", rule.ruleId);
            console2.log("   target:", uint256(rule.target));
            console2.log("   hasBadge:", hasRule);
        }
    }
}
