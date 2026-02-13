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

## [2026-02-13T00:00:00Z] Task 3: Dev package consolidation
- Moved to development.nix: gcc, mold, openssl, pkg-config, solc, codex-cli-nix, opencode
- Moved session variables: PKG_CONFIG_PATH
- Moved programs: pyenv.enable = true
- Moved import: solana.nix now in development.nix (inherited by all dev environments)
- PC-only packages kept: pavucontrol, vesktop, slack, spotify, jetbrains.datagrip, jetbrains.goland, prismlauncher, openjdk25, glfw, obsidian, audacity, telegram-desktop, signal-desktop, anki-bin
- VM now inherits all dev tools via development.nix import
- Removed solana.nix import from pc.nix and macbook-vm.nix (now in development.nix)
- All 3 configs pass flake check validation

## [2026-02-13T00:00:00Z] Task 2: Shared NixOS base module
- Created modules/nixos/base.nix with shared settings
- Extracted: nixpkgs config, nix settings, locale, timezone, zsh, user definition, system packages
- Used lib.mkDefault for extraGroups to allow host-specific overrides
- PC-specific kept: boot, audio, networking.hostName, hyprland, nvidia, keyring, xremap
- VM-specific kept: networking.hostName, orbstack imports, docker config, nixpkgs.hostPlatform
- Build verification: macbook config builds successfully, PC/VM configs fail as expected (wrong architecture)
- Both host files now import ../../modules/nixos/base.nix and override extraGroups appropriately

## [2026-02-13T00:00:00Z] Task 4: Split zed.nix concerns
- **zed.nix refactored**: Now pure config-sync module (options + activation script only)
  - Removed: `pkgs.zed-editor` from home.packages
  - Removed: `import ./zed-lsp.nix` from imports
  - Kept: `extensions.zed` option definitions (settingsPath, keymapPath)
  - Kept: `home.activation.zedResetConfig` script for config file sync
- **gui.nix enhanced**: Now bundles Zed package + LSP servers + config module
  - Added: `pkgs.zed-editor` to home.packages
  - Added: `import ../programs/zed-lsp.nix` for LSP servers
  - Kept: `import ../programs/zed.nix` for config sync
- **Separation enables flexible deployment**:
  - PC (via gui.nix): Gets Zed package + LSP servers + config sync
  - Macbook (imports zed.nix directly): Gets config sync only
  - VM (imports zed-lsp.nix directly): Gets LSP servers only
- **Verification**: Both modified files parse correctly (nix-instantiate)
- **User configs unchanged**: macbook.nix and pc.nix still use extensions.zed options
