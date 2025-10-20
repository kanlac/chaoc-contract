SHELL := /bin/bash
.DEFAULT_GOAL := help

FORGE ?= forge

.PHONY: help test-unit fmt clean build deps

help:
	@echo "Common tasks:"
	@echo "  make deps          # fetch git submodule dependencies"
	@echo "  make test-unit     # run unit test suite"
	@echo "  make fmt           # format Solidity sources"
	@echo "  make build         # compile contracts"
	@echo "  make clean         # clean build artifacts"

test-unit:
	@$(FORGE) test

fmt:
	@$(FORGE) fmt

build:
	@$(FORGE) build

clean:
	@$(FORGE) clean

deps:
	@git submodule update --init --recursive
