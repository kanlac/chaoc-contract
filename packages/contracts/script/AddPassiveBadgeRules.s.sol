// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {BadgeRuleRegistry} from "../src/BadgeRuleRegistry.sol";

/// @notice Registers the remaining passive badge rules (IDs 2-5) if they do not exist yet.
contract AddPassiveBadgeRules is Script {
    struct RuleDefinition {
        uint256 ruleId;
        BadgeRuleRegistry.BadgeTarget target;
        uint256 threshold;
        string metadataURI;
    }

    RuleDefinition[] internal _rules;

    constructor() {
        _rules.push(
            RuleDefinition({
                ruleId: 2,
                target: BadgeRuleRegistry.BadgeTarget.Buyer,
                threshold: 3,
                metadataURI: "ipfs://badge/buyer-three-purchases.json"
            })
        );
        _rules.push(
            RuleDefinition({
                ruleId: 3,
                target: BadgeRuleRegistry.BadgeTarget.Creator,
                threshold: 1,
                metadataURI: "ipfs://badge/creator-one-sale.json"
            })
        );
        _rules.push(
            RuleDefinition({
                ruleId: 4,
                target: BadgeRuleRegistry.BadgeTarget.Creator,
                threshold: 3,
                metadataURI: "ipfs://badge/creator-three-sales.json"
            })
        );
        _rules.push(
            RuleDefinition({
                ruleId: 5,
                target: BadgeRuleRegistry.BadgeTarget.Creator,
                threshold: 10_000_000, // 10 USDT with 6 decimals
                metadataURI: "ipfs://badge/creator-ten-usdt-volume.json"
            })
        );
    }

    function run() external {
        address registryAddr = vm.envAddress("BADGE_RULE_REGISTRY_ADDRESS");
        uint256 ownerKey = vm.envOr("REGISTRY_OWNER_PRIVATE_KEY", uint256(0));
        BadgeRuleRegistry registry = BadgeRuleRegistry(registryAddr);

        console2.log("== Add Passive Badge Rules ==");
        console2.log("Registry:", registryAddr);

        if (ownerKey != 0) {
            vm.startBroadcast(ownerKey);
            console2.log("Broadcaster:", vm.addr(ownerKey));
        } else {
            vm.startBroadcast();
            console2.log("Broadcaster:", tx.origin);
        }
        for (uint256 i = 0; i < _rules.length; i++) {
            RuleDefinition memory def = _rules[i];
            if (registry.ruleExists(def.ruleId)) {
                console2.log("Rule already exists:", def.ruleId);
                continue;
            }

            registry.createRule(
                BadgeRuleRegistry.BadgeRuleInput({
                    ruleId: def.ruleId,
                    trigger: BadgeRuleRegistry.TriggerType.Passive,
                    target: def.target,
                    threshold: def.threshold,
                    metadataURI: def.metadataURI,
                    enabled: true
                })
            );

            console2.log("Created rule:", def.ruleId);
        }
        vm.stopBroadcast();
    }
}
