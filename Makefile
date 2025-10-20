SHELL := /bin/bash
.DEFAULT_GOAL := help

FORGE ?= forge

.PHONY: help test-unit test-marketplace fmt clean build deps deploy-sepolia

help:
	@echo "Common tasks:"
	@echo "  make deps          # fetch git submodule dependencies"
	@echo "  make test-unit     # run unit test suite"
	@echo "  make test-marketplace # run marketplace scenario tests"
	@echo "  make fmt           # format Solidity sources"
	@echo "  make build         # compile contracts"
	@echo "  make clean         # clean build artifacts"
	@echo "  make deploy-sepolia # deploy contracts to Sepolia using env credentials"

test-unit:
	@$(FORGE) test

test-marketplace:
	@$(FORGE) test --match-path test/marketplace/Marketplace_Purchase.t.sol

fmt:
	@$(FORGE) fmt

build:
	@$(FORGE) build

clean:
	@$(FORGE) clean

deps:
	@git submodule update --init --recursive

deploy-sepolia:
	@if [ -f .env ]; then set -a && . .env && set +a; fi; \
	if [ -z "$$SEPOLIA_RPC_URL" ]; then echo "SEPOLIA_RPC_URL is not set"; exit 1; fi; \
	if [ -z "$$PRIVATE_KEY" ]; then echo "PRIVATE_KEY is not set"; exit 1; fi; \
	$(FORGE) script script/DeployReputation.s.sol \
		--rpc-url "$$SEPOLIA_RPC_URL" \
		--broadcast \
		--slow \
		--private-key "$$PRIVATE_KEY"
