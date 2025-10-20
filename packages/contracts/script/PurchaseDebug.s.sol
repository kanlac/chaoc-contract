// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {Marketplace} from "../src/Marketplace.sol";
import {IdentityToken} from "../src/IdentityToken.sol";
import {ReputationBadge} from "../src/ReputationBadge.sol";
import {BadgeRuleRegistry} from "../src/BadgeRuleRegistry.sol";
import {IMintableERC20} from "../src/interfaces/IMintableERC20.sol";

/// @notice Replays a purchase for troubleshooting and verifies buyer identity/badge state.
contract PurchaseDebug is Script {
    function run() external {
        address marketplaceAddr = vm.envAddress("MARKETPLACE_ADDRESS");
        uint256 buyerKey = vm.envUint("BUYER_PRIVATE_KEY");
        string memory workSlug = vm.envOr("WORK_SLUG", string("debug-work"));
        uint256 mintBuffer = vm.envOr("MINT_BUFFER", uint256(0));
        bool skipMint = vm.envOr("SKIP_MINT", false);

        Marketplace marketplace = Marketplace(marketplaceAddr);
        bytes32 workId = keccak256(bytes(workSlug));

        Marketplace.Listing memory listing = marketplace.getWork(workId);
        require(listing.creator != address(0), "PurchaseDebug: work not listed");
        require(listing.active, "PurchaseDebug: work inactive");

        address buyer = vm.addr(buyerKey);
        vm.label(buyer, "buyer");

        IMintableERC20 settlementToken = marketplace.settlementToken();
        uint256 mintAmount = listing.price + mintBuffer;

        console2.log("== Marketplace Purchase Debug ==");
        console2.log("Marketplace:", marketplaceAddr);
        console2.log("Settlement token:", address(settlementToken));
        console2.log("Buyer:", buyer);
        console2.logBytes32(workId);
        console2.log("Listing price:", listing.price);

        vm.startBroadcast(buyerKey);
        if (!skipMint) {
            settlementToken.mint(buyer, mintAmount);
            console2.log("Minted tokens for buyer:", mintAmount);
        }
        settlementToken.approve(marketplaceAddr, type(uint256).max);
        marketplace.purchase(workId);
        vm.stopBroadcast();

        IdentityToken identity = marketplace.identityToken();
        bool hasIdentity = identity.hasIdentity(buyer);
        console2.log("Buyer identity minted:", hasIdentity);
        if (hasIdentity) {
            console2.log("Buyer identity tokenId:", identity.tokenIdOf(buyer));
        }

        ReputationBadge badge = marketplace.reputationBadge();
        uint256[] memory badgeIds = badge.badgeIdsOf(buyer);
        console2.log("Buyer badge count:", badgeIds.length);
        for (uint256 i = 0; i < badgeIds.length; i++) {
            uint256 badgeId = badgeIds[i];
            console2.log(" - badgeId:", badgeId);
            console2.log("   ruleId:", badge.badgeRule(badgeId));
        }

        BadgeRuleRegistry registry = marketplace.badgeRuleRegistry();
        uint256 ruleCount = registry.ruleCount();
        console2.log("Buyer badge matches registry rules:");
        for (uint256 i = 0; i < ruleCount; i++) {
            uint256 ruleId = registry.ruleIdAt(i);
            BadgeRuleRegistry.BadgeRule memory rule = registry.getRule(ruleId);
            if (rule.target == BadgeRuleRegistry.BadgeTarget.Buyer) {
                bool hasRuleBadge = badge.hasBadge(buyer, ruleId);
                console2.log(" - ruleId:", ruleId, "hasBadge:", hasRuleBadge);
            }
        }

        Marketplace.BuyerStat memory buyerStat = marketplace.getBuyerStat(buyer);
        console2.log("Buyer total purchases:", buyerStat.totalPurchases);
        console2.log("Buyer total volume:", buyerStat.totalVolume);
    }
}
