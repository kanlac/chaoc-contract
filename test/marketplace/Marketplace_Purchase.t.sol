// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Marketplace} from "../../contracts/Marketplace.sol";
import {ReputationDataFeed} from "../../contracts/ReputationDataFeed.sol";
import {MockERC20} from "../../contracts/mocks/MockERC20.sol";
import {IMintableERC20} from "../../contracts/interfaces/IMintableERC20.sol";
import {BadgeRuleRegistry} from "../../contracts/BadgeRuleRegistry.sol";
import {BaseReputationTest} from "../utils/BaseReputationTest.sol";

contract MarketplacePurchaseTest is BaseReputationTest {
    Marketplace internal marketplace;
    ReputationDataFeed internal dataFeed;
    MockERC20 internal usdt;

    bytes32 internal constant WORK_ID = keccak256("work-1");
    bytes32 internal constant PURCHASE_ID = keccak256("purchase-1");
    uint256 internal constant WELCOME_AMOUNT = 10_000_000;

    function setUp() public virtual override {
        BaseReputationTest.setUp();

        usdt = new MockERC20("Mock USDT", "mUSDT", 6);
        dataFeed = new ReputationDataFeed();

        badgeRuleRegistry.createRule(defaultBadgeRule());

        BadgeRuleRegistry.BadgeRuleInput memory creatorRule = BadgeRuleRegistry.BadgeRuleInput({
            ruleId: 3,
            trigger: BadgeRuleRegistry.TriggerType.Passive,
            target: BadgeRuleRegistry.BadgeTarget.Creator,
            threshold: 1,
            metadataURI: "ipfs://badge/creator-one-sale.json",
            enabled: true
        });
        badgeRuleRegistry.createRule(creatorRule);

        marketplace = new Marketplace(
            IMintableERC20(address(usdt)),
            identityToken,
            reputationBadge,
            badgeRuleRegistry,
            dataFeed,
            "ipfs://identity/default.json",
            WELCOME_AMOUNT
        );

        identityToken.transferOwnership(address(marketplace));
        reputationBadge.transferOwnership(address(marketplace));

        dataFeed.setMarketplace(address(marketplace));

        vm.prank(creator);
        marketplace.listWork(WORK_ID, 10_000_000); // 10 USDT with 6 decimals
    }

    function _approveBuyer(uint256 amount) internal {
        vm.prank(buyer);
        usdt.approve(address(marketplace), amount);
    }

    function testPurchaseMintsIdentityAndAwardsBadges() public {
        _approveBuyer(10_000_000);

        vm.expectEmit(true, true, true, true);
        emit Marketplace.PurchaseCompleted(buyer, creator, WORK_ID, PURCHASE_ID, 10_000_000);

        vm.prank(buyer);
        marketplace.purchase(WORK_ID, PURCHASE_ID);

        assertTrue(identityToken.hasIdentity(buyer), "identity not minted");
        assertTrue(reputationBadge.hasBadge(buyer, 1), "buyer badge missing");
        assertTrue(reputationBadge.hasBadge(creator, 3), "creator badge missing");

        assertEq(usdt.balanceOf(creator), 10_000_000, "creator payment mismatch");

        ReputationDataFeed.BuyerStat memory buyerStat = dataFeed.getBuyerStat(buyer);
        assertEq(buyerStat.totalPurchases, 1, "buyer purchase count mismatch");
        assertEq(buyerStat.totalVolume, 10_000_000, "buyer volume mismatch");

        ReputationDataFeed.CreatorStat memory creatorStat = dataFeed.getCreatorStat(creator);
        assertEq(creatorStat.totalSales, 1, "creator sales mismatch");
        assertEq(creatorStat.totalVolume, 10_000_000, "creator volume mismatch");
    }

    function testDuplicatePurchaseIdReverts() public {
        _approveBuyer(10_000_000);

        vm.prank(buyer);
        marketplace.purchase(WORK_ID, PURCHASE_ID);

        vm.prank(buyer);
        vm.expectRevert(Marketplace.PurchaseAlreadyProcessed.selector);
        marketplace.purchase(WORK_ID, PURCHASE_ID);
    }
}
