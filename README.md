# Chaoc Monorepo

This repository now follows a layered mono-repo layout so that smart contracts, application clients, and shared resources live under the same roof.

## Layout
- `packages/contracts` – Foundry project with Solidity sources, tests, scripts, and build artefacts.
- `packages/shared` – placeholder for cross-cutting TypeScript/JS/Rust/Python utilities (e.g., generated types, SDK helpers).
- `apps/web` – placeholder for the primary web client.
- `apps/api` – placeholder for backend or BFF services.
- `tooling` – automation, CI glue, deployment recipes, or infra-as-code modules.
- `docs` – architecture notes, integration guides, and ABI exports.

## Working with contracts
- run `forge test` from the repo root (config points to `packages/contracts`).
- run `forge build` or `make build` to compile and refresh ABI dumps under `docs/reputation-interface-pack/`.
- scripts live under `packages/contracts/script`; use `forge script` via the Makefile targets (e.g., `make deploy-sepolia`).

## Adding new layers
- frontends belong under `apps/` (create folders like `apps/web` or `apps/mobile`).
- backend/BFF services can be added under `apps/api` or `apps/<service-name>`.
- shared tooling or generated bindings should live under `packages/shared` so that multiple apps can import them without duplication.
- repo-level automation (linting, CI, infrastructure) should land in `tooling/` with clear READMEs explaining usage.
