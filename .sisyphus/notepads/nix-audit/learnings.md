# Learnings - nix-audit

## Conventions and Patterns

(Tasks will append findings here)

## [2026-02-13T00:00:00Z] Task 1: Dead weight removal
- Deleted: plan.md, lib/, modules/darwin/, modules/shared/
- Removed unused flake inputs: browser-previews, prismlauncher
- Electron-27.3.11 allowance: REMOVED because obsidian-1.11.5 is not marked as insecure in nixpkgs-unstable
- Foundry overlay: UNUSED - no references to foundry, forge, cast, or anvil found in any configuration files
- flake.lock updated after input removal
- Build verification: macbook (aarch64-darwin) config builds successfully; pc and macbook-vm configs cannot be evaluated on aarch64-darwin (expected - they target x86_64-linux and aarch64-linux respectively)
