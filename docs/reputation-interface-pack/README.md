# 链上声誉系统 ABI 交付包

本目录提供《docs/foundry-reputation-system.md》中涉及的关键合约 ABI 及说明，方便前端、脚本和集成团队快速落地。若后续 Solidity 实现与此差异，请在编译产物生成后用实际 ABI 覆盖并同步更新本文档。

## 文件清单
- `IdentityToken.abi.json`：EIP-4973 身份合约入口。
- `ReputationBadge.abi.json`：EIP-5114 徽章合约。
- `BadgeRuleRegistry.abi.json`：徽章规则仓库。
- `Marketplace.abi.json`：作品交易与声誉逻辑主合约。
- `ReputationDataFeed.abi.json`：聚合数据喂价合约。

## 接口摘要

### IdentityToken
- `mintSelf(string metadataURI)`：用户自助铸造身份 NFT，返回 `tokenId`。
- `attest(address account, string metadataURI)`：市场或运营合约代为铸造；需具备授权角色。
- 查询接口：`hasIdentity`, `tokenIdOf`, `tokenURI`, `ownerOf`, `balanceOf`, `supportsInterface`。
- 事件：`IdentityMinted`, `IdentityRevoked`。

### ReputationBadge
- 发放徽章：`issueBadge(account, ruleId)`, `issueBatch(ruleId, accounts)`。
- 查询：`hasBadge`, `badgesOf(account)`（返回 `ruleIds` 与 `badgeIds`，便于前端展示），`badgeURI`, `ruleIdOf`, `totalSupply`, `balanceOf`, `supportsInterface`。
- 事件：`BadgeMinted`, `BadgeRevoked`。

### BadgeRuleRegistry
- 管理：`createRule(BadgeRuleInput)`, `updateRule(ruleId, BadgeRuleUpdate)`, `setRuleStatus(ruleId, enabled)`。
- 查询：`getRule`, `getRules(offset, limit)`, `ruleCount`, `ruleExists`。
- 事件：`BadgeRuleCreated`, `BadgeRuleUpdated`。

### Marketplace
- 交易流程：`listWork(workId, Listing, signature)`, `deactivateWork(workId)`, `purchase(workId)`。
- 徽章评估：`getEligibleRules(account, target)`, `issueMonthlyBadges(ruleId, startIndex, batchSize)`。
- 数据读取：`getWork`, `getBuyerStat`, `getCreatorStat`, `creatorRegistryLength`, `creatorAt`。
- 配置：`setBadgeContract`, `setBadgeRuleRegistry`, `setDataFeed`，以及 `badgeContract`, `badgeRuleRegistry`, `dataFeed` 查询。
- 权限：遵循 `AccessControl`，可用 `grantRole`, `revokeRole`, `renounceRole`, `hasRole`, `getRoleAdmin`。
- 事件：`WorkListed`, `WorkDeactivated`, `PurchaseCompleted`, `BadgeIssued`。

### ReputationDataFeed
- 写入：`syncBuyerStat(account, BuyerStat)`, `syncCreatorStat(account, CreatorStat)`。
- 查询：`getBuyerStat`, `getCreatorStat`, `marketplace`, `supportsInterface`。
- 管理：`setMarketplace` 设置唯一写入方。
- 事件：`BuyerStatSynced`, `CreatorStatSynced`。

## 使用建议
- **ABI 导入**：复制对应 JSON 到前端或脚本项目，以 `ethers.js` / `viem` / `web3.py` 等工具生成类型定义。
- **角色权限**：部署后记录 `MARKET_ADMIN`、`OPERATOR`、`DATA_WRITER` 等角色地址，避免未授权的敏感调用。
- **签名与安全**：`listWork` 调用需使用 EIP-712 数据结构；确保链外签名与链上验证字段一致。
- **对齐实现**：当 Solidity 实现确定后，应以编译得到的 ABI 取代占位版本，防止参数或返回值不匹配。

如需扩展（例如 Merkle 领取、更多统计字段），请在更新合约同时扩充相应 ABI 条目，并在文档中补充描述。*** End Patch
