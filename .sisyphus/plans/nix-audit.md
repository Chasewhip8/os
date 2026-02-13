# Nix Repository Audit & Cleanup

## TL;DR

> **Quick Summary**: Comprehensive audit and cleanup of a 3-environment Nix configuration (NixOS PC, macOS Macbook, NixOS OrbStack VM). Eliminate duplication, fix incorrect profile composition, remove dead weight, and ensure each environment gets exactly what it needs — nothing more.
> 
> **Deliverables**:
> - Cleaned flake.nix (deduplicated overlays, removed unused inputs)
> - New shared NixOS base module (modules/nixos/base.nix)
> - Consolidated development.nix profile with all dev tools
> - Split zed.nix into package vs config-sync concerns
> - Correct profile composition per environment
> - Removed dead files/directories
> 
> **Estimated Effort**: Medium
> **Parallel Execution**: YES - 2 waves
> **Critical Path**: Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6 → Task 7

---

## Context

### Original Request
Comprehensive audit of the Nix repository managing 3 environments. Maintain straightforward, concise, easy-to-read configurations. No backwards compatibility constraints — everything can change.

### Interview Summary
**Key Discussions**:
- Macbook should be GUI-only (no dev tools), but currently imports development.nix
- Zed and Kitty are double-installed on Macbook (Nix + Homebrew)
- Dev packages duplicated between PC and VM user configs
- NixOS settings duplicated between PC and VM host configs
- Multiple dead artifacts (empty dirs, unused inputs, stale plan.md)

**User Decisions**:
- macOS GUI apps → Homebrew casks only, remove Nix packages
- Merge duplicated dev packages into development.nix
- Create modules/nixos/base.nix for shared NixOS settings
- Add opencode to macbook-vm
- Clean up all dead weight

### Metis Review
**Identified Gaps** (addressed):
- Zed activation script (config sync) must survive on macbook even though Zed binary comes from Homebrew — **addressed via zed.nix split in Task 4**
- Kitty config management (programs.kitty) should remain on macbook for `~/.config/kitty/kitty.conf` — **addressed: keep programs.kitty in macbook's profile since home-manager writes config regardless of install source**
- PKG_CONFIG_PATH and pyenv.enable also duplicated — **addressed: merged into development.nix in Task 3**
- foundry.overlay may be unused — **addressed: verify in Task 1**
- electron-27.3.11 insecure allowance may be stale — **addressed: verify in Task 1**
- Must NOT touch orbstack.nix, hyprland subtree, or stateVersion values
- Build verification needed at each step, not just at the end

---

## Work Objectives

### Core Objective
Make the 3-environment Nix config correct, DRY, and easy to understand — each environment gets exactly what it needs with zero duplication.

### Concrete Deliverables
- `flake.nix` — deduplicated overlays, removed `browser-previews` and `prismlauncher` inputs
- `modules/nixos/base.nix` — shared NixOS settings (locale, nix config, user, zsh, system packages)
- `home/profiles/development.nix` — consolidated with all dev tools (gcc, mold, openssl, etc.)
- `home/programs/zed.nix` — split so config sync is separable from package install
- `home/users/chase/macbook.nix` — correct imports (no development.nix, no gui.nix)
- `home/users/chase/pc.nix` — cleaned of packages now in development.nix
- `home/users/chase/macbook-vm.nix` — cleaned of packages now in development.nix, add opencode
- Deleted: `plan.md`, `lib/`, `modules/darwin/`, `modules/shared/`
- Cleaned: commented-out macOS defaults (either configure or remove)

### Definition of Done
- [x] All 3 configs evaluate: `nix build --dry-run` passes for pc, macbook, macbook-vm
- [x] Macbook has ZERO dev packages (no nodejs, bun, rust, go, gcc, etc.)
- [x] Macbook still has Zed config sync activation (`zedResetConfig`)
- [x] Macbook still has Kitty config management (programs.kitty)
- [x] VM has opencode
- [x] No duplicate package declarations between pc.nix and macbook-vm.nix
- [x] No duplicate settings between hosts/pc and hosts/macbook-vm
- [x] No references to browser-previews or prismlauncher in flake.nix
- [x] plan.md, lib/, modules/darwin/, modules/shared/ deleted

### Must Have
- Build verification after each structural change
- Zed config sync preserved on macbook
- Kitty config writing preserved on macbook
- All dev tools available on PC and VM
- opencode on VM

### Must NOT Have (Guardrails)
- Do NOT touch `hosts/macbook-vm/orbstack.nix` (auto-generated, will be overwritten)
- Do NOT touch anything in `home/programs/hyprland/` (working, PC-only)
- Do NOT change any `stateVersion` values (system or home)
- Do NOT include `hostPlatform` in shared base.nix (host-specific)
- Do NOT add abstractions/options/conditionals to base.nix (just move literal config)
- Do NOT restructure `modules/nixos/` directory beyond adding base.nix
- Do NOT restructure `home/programs/` directory
- Do NOT add new Nix options or complex conditional logic — keep it flat and explicit

---

## Verification Strategy

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL verification is via `nix build --dry-run`, `nix eval`, and `grep`.

### Test Decision
- **Infrastructure exists**: NO (Nix configurations, not a software project)
- **Automated tests**: NO
- **Framework**: N/A — verification is nix evaluation/build

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

**Verification Tool**: Bash (nix commands, grep)

After EVERY task, the executing agent MUST run:
```bash
# Build verification for all 3 configs
nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1
nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run 2>&1
nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1
```

If any fails, the change MUST be reverted and fixed before proceeding.

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — zero functional impact):
├── Task 1: Dead weight removal + verification of stale items
└── (sequential within wave)

Wave 2 (After Wave 1 — refactoring, behavior-preserving):
├── Task 2: Create modules/nixos/base.nix
├── Task 3: Consolidate development.nix (parallel with Task 2)
└── Task 4: Split zed.nix (parallel with Task 2 and 3)

Wave 3 (After Wave 2 — intentional behavior changes):
├── Task 5: Restructure macbook profile composition
├── Task 6: Restructure PC and VM user configs
└── Task 7: Clean up flake.nix overlays
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 2, 3, 4 | None |
| 2 | 1 | 5, 6 | 3, 4 |
| 3 | 1 | 5, 6 | 2, 4 |
| 4 | 1 | 5 | 2, 3 |
| 5 | 2, 3, 4 | None | 6, 7 |
| 6 | 2, 3 | None | 5, 7 |
| 7 | 1 | None | 5, 6 |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1 | task(category="quick", load_skills=[], ...) |
| 2 | 2, 3, 4 | task(category="quick", load_skills=[], ...) dispatched in parallel |
| 3 | 5, 6, 7 | task(category="quick", load_skills=[], ...) dispatched in parallel |

---

## TODOs

- [x] 1. Remove dead weight and verify stale items

  **What to do**:
  - Delete `plan.md` from repository root
  - Delete empty directories: `lib/`, `modules/darwin/`, `modules/shared/`
  - Remove `browser-previews` input from `flake.nix` (lines 37-40) — confirmed unused in all .nix files
  - Remove `prismlauncher` input from `flake.nix` (lines 42-44) — `pc.nix` uses `pkgs.prismlauncher` from nixpkgs, NOT from this input
  - Remove commented-out `system.defaults` block from `hosts/macbook/default.nix` (lines 57-71) — replace with an empty attrset or remove the key entirely
  - **Verify**: Check if `electron-27.3.11` insecure allowance in `hosts/pc/default.nix:30` is still needed. Run `nix eval .#nixosConfigurations.pc.config.home-manager.users.chase.home.packages --apply 'map (p: p.name)' 2>&1 | grep -i obsidian`. If Obsidian is present, temporarily remove the allowance and check if build still passes. If build fails, keep it with a comment explaining why. If build passes, remove it.
  - **Verify**: Check if `foundry.overlay` is actually providing packages used anywhere. Run `nix eval .#nixosConfigurations.pc.config.environment.systemPackages --apply 'map (p: p.name)' 2>&1 | grep -iE 'forge|cast|anvil|foundry'` and similar for home packages. If nothing references foundry tools, note it for Task 7 (remove the overlay and input). If something uses it, keep it.
  - Run `nix flake lock` after removing inputs to update flake.lock
  - Build-verify all 3 configs

  **Must NOT do**:
  - Do NOT remove `prismlauncher` from `pc.nix` home.packages — it's a valid package from nixpkgs, just the flake input is unused
  - Do NOT touch orbstack.nix
  - Do NOT remove `foundry` input/overlay yet — just verify usage. Removal happens in Task 7 if confirmed unused.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: File deletions, grep checks, and simple nix eval commands
  - **Skills**: []
    - No specialized skills needed — all bash operations

  **Parallelization**:
  - **Can Run In Parallel**: NO (foundational — all other tasks depend on clean state)
  - **Parallel Group**: Wave 1 (solo)
  - **Blocks**: Tasks 2, 3, 4, 5, 6, 7
  - **Blocked By**: None

  **References**:
  
  **Pattern References**:
  - `flake.nix:37-44` — browser-previews and prismlauncher inputs to remove
  - `flake.nix:57` — foundry input to verify usage
  - `hosts/macbook/default.nix:57-71` — commented-out system.defaults to clean up
  - `hosts/pc/default.nix:30` — electron-27.3.11 insecure allowance to verify

  **Acceptance Criteria**:

  ```
  Scenario: Dead weight removed
    Tool: Bash
    Steps:
      1. ls plan.md 2>&1 → Assert: "No such file or directory"
      2. ls lib/ 2>&1 → Assert: "No such file or directory"
      3. ls modules/darwin/ 2>&1 → Assert: "No such file or directory"
      4. ls modules/shared/ 2>&1 → Assert: "No such file or directory"
      5. grep -c 'browser-previews' flake.nix → Assert: 0
      6. grep -c 'prismlauncher' flake.nix → Assert: 0
      7. grep -c 'commented-out\|# dock\|# finder\|# NSGlobalDomain' hosts/macbook/default.nix → Assert: 0
    Expected Result: All dead weight removed

  Scenario: All 3 configs still build
    Tool: Bash
    Steps:
      1. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      2. nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      3. nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
    Expected Result: All builds pass
  ```

  **Commit**: YES
  - Message: `chore: remove dead weight (unused inputs, empty dirs, stale plan.md)`
  - Files: `flake.nix`, `flake.lock`, `hosts/macbook/default.nix`, `hosts/pc/default.nix` (if insecure pkg removed), deleted files
  - Pre-commit: `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run`

---

- [x] 2. Create shared NixOS base module

  **What to do**:
  - Create `modules/nixos/base.nix` containing the settings duplicated between `hosts/pc/default.nix` and `hosts/macbook-vm/default.nix`:
    - `nixpkgs.config.allowUnfree = true`
    - `nix.settings.experimental-features = [ "nix-command" "flakes" ]`
    - `nix.settings.trusted-users = [ "root" "@wheel" "chase" ]`
    - `time.timeZone = "America/Boise"`
    - `i18n.defaultLocale = "en_US.UTF-8"` and the full `i18n.extraLocaleSettings` block
    - `programs.zsh.enable = true`
    - `environment.systemPackages = with pkgs; [ git wget ]`
    - `programs.nix-ld.enable = true`
    - User definition: `users.users.chase = { uid = 1000; isNormalUser = true; shell = pkgs.zsh; description = "Chase"; extraGroups = [ "wheel" ]; }`
  - Import `../../modules/nixos/base.nix` from both `hosts/pc/default.nix` and `hosts/macbook-vm/default.nix`
  - Remove the duplicated lines from both host files
  - **For PC**: Keep PC-specific additions inline: `extraGroups` adds `"networkmanager"` (use `lib.mkForce` or define in pc host as `users.users.chase.extraGroups = [ "networkmanager" "wheel" ];`), `networking.hostName`, boot config, audio, printing, keyring, etc.
  - **For VM**: Keep VM-specific additions inline: `extraGroups` adds `"docker"`, `networking.hostName`, OrbStack imports, etc.
  - **Note on user extraGroups**: base.nix should set the common groups `[ "wheel" ]`. Each host appends its own groups. Use `users.users.chase.extraGroups = lib.mkDefault [ "wheel" ];` in base, then override in hosts with the full list.
  - Build-verify all 3 configs

  **Must NOT do**:
  - Do NOT include `hostPlatform` (host-specific)
  - Do NOT include `networking.hostName` (host-specific)
  - Do NOT include `boot.*` settings (PC-specific)
  - Do NOT include audio/pipewire settings (PC-specific)
  - Do NOT add options or conditionals — just literal config
  - Do NOT include `nixpkgs.config.permittedInsecurePackages` (PC-specific, if still present)
  - Do NOT change any `system.stateVersion` values

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Creating one new file, editing two existing files — straightforward extraction
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3, 4)
  - **Blocks**: Tasks 5, 6
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `hosts/pc/default.nix:29-53` — Nix settings, locale, extraLocaleSettings block to extract
  - `hosts/macbook-vm/default.nix:21-49` — Identical settings to extract
  - `hosts/pc/default.nix:76-94` — User definition and zsh enable
  - `hosts/macbook-vm/default.nix:49-61` — User definition and zsh enable

  **Acceptance Criteria**:

  ```
  Scenario: Shared base module exists and is imported
    Tool: Bash
    Steps:
      1. test -f modules/nixos/base.nix → Assert: exit code 0
      2. grep -c 'base.nix' hosts/pc/default.nix → Assert: 1
      3. grep -c 'base.nix' hosts/macbook-vm/default.nix → Assert: 1
    Expected Result: base.nix exists and is imported by both NixOS hosts

  Scenario: No duplicated settings remain
    Tool: Bash
    Steps:
      1. grep -c 'extraLocaleSettings' hosts/pc/default.nix → Assert: 0
      2. grep -c 'extraLocaleSettings' hosts/macbook-vm/default.nix → Assert: 0
      3. grep -c 'experimental-features' hosts/pc/default.nix → Assert: 0
      4. grep -c 'experimental-features' hosts/macbook-vm/default.nix → Assert: 0
    Expected Result: Duplicated config only in base.nix

  Scenario: All 3 configs still build
    Tool: Bash
    Steps:
      1. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      2. nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      3. nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
    Expected Result: All builds pass
  ```

  **Commit**: YES
  - Message: `refactor: extract shared NixOS settings into modules/nixos/base.nix`
  - Files: `modules/nixos/base.nix` (new), `hosts/pc/default.nix`, `hosts/macbook-vm/default.nix`
  - Pre-commit: `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run`

---

- [x] 3. Consolidate dev packages into development.nix

  **What to do**:
  - Add to `home/profiles/development.nix` the packages currently duplicated in pc.nix and macbook-vm.nix:
    - `pkgs.gcc`
    - `pkgs.mold`
    - `pkgs.openssl`
    - `pkgs.pkg-config`
    - `pkgs.solc`
    - `inputs.codex-cli-nix.packages.${pkgs.system}.default`
    - `pkgs.opencode`
  - Add to `home/profiles/development.nix` the session variables and programs:
    - `home.sessionVariables.PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";`
    - `programs.pyenv.enable = true;`
  - Add `solana.nix` import to development.nix: `imports = [ ../programs/solana.nix ];`
  - Remove all the above from `home/users/chase/pc.nix` and `home/users/chase/macbook-vm.nix`
  - Remove the separate `../../programs/solana.nix` import from pc.nix and macbook-vm.nix (now in development.nix)
  - Note: `inputs` is already available in development.nix via the function args `{ pkgs, inputs, ... }:`
  - Build-verify all 3 configs

  **Must NOT do**:
  - Do NOT move PC-only packages (pavucontrol, vesktop, slack, spotify, jetbrains, prismlauncher, obsidian, audacity, telegram, signal, anki, openjdk, glfw) — these stay in pc.nix
  - Do NOT move macbook-specific packages — macbook doesn't import development.nix after Task 5
  - Do NOT touch the `home.shellAliases` (host-specific rebuild commands)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Moving package declarations between files — mechanical refactoring
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 4)
  - **Blocks**: Tasks 5, 6
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `home/profiles/development.nix:1-20` — Current development profile (add packages here)
  - `home/users/chase/pc.nix:28-49` — PC packages to deduplicate (extract gcc, mold, openssl, pkg-config, solc, codex-cli)
  - `home/users/chase/pc.nix:57-59` — PKG_CONFIG_PATH to move
  - `home/users/chase/pc.nix:62` — pyenv to move
  - `home/users/chase/macbook-vm.nix:21-28` — VM packages to deduplicate
  - `home/users/chase/macbook-vm.nix:36-38` — PKG_CONFIG_PATH to move
  - `home/users/chase/macbook-vm.nix:41` — pyenv to move
  - `home/programs/solana.nix:1-14` — Solana CLI import to add to development.nix

  **Acceptance Criteria**:

  ```
  Scenario: Dev packages consolidated
    Tool: Bash
    Steps:
      1. grep -c 'gcc\|pkgs.mold\|pkgs.openssl\b\|pkg-config\|pkgs.solc\|codex-cli' home/profiles/development.nix → Assert: >= 6
      2. grep -c 'pkgs.gcc\|pkgs.mold\|pkgs.openssl\b\|pkg-config\|pkgs.solc\|codex-cli' home/users/chase/pc.nix → Assert: 0
      3. grep -c 'pkgs.gcc\|pkgs.mold\|pkgs.openssl\b\|pkg-config\|pkgs.solc\|codex-cli' home/users/chase/macbook-vm.nix → Assert: 0
      4. grep -c 'solana' home/profiles/development.nix → Assert: >= 1
      5. grep -c 'solana' home/users/chase/pc.nix → Assert: 0
      6. grep -c 'solana' home/users/chase/macbook-vm.nix → Assert: 0
      7. grep -c 'pyenv' home/profiles/development.nix → Assert: >= 1
      8. grep -c 'PKG_CONFIG_PATH' home/profiles/development.nix → Assert: >= 1
    Expected Result: All dev packages in development.nix only

  Scenario: All 3 configs still build
    Tool: Bash
    Steps:
      1. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      2. nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      3. nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
    Expected Result: All builds pass
  ```

  **Commit**: YES
  - Message: `refactor: consolidate dev packages into development.nix profile`
  - Files: `home/profiles/development.nix`, `home/users/chase/pc.nix`, `home/users/chase/macbook-vm.nix`
  - Pre-commit: `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run`

---

- [x] 4. Split zed.nix into package install vs config sync

  **What to do**:
  - Currently `home/programs/zed.nix` does TWO things:
    1. Installs `pkgs.zed-editor` as a Nix package
    2. Defines `extensions.zed` options and runs an activation script to copy settings/keymap
  - Also, `zed.nix` imports `zed-lsp.nix` unconditionally
  - **Restructure** `zed.nix` to ONLY contain the options definition and activation script (config sync). Remove the `pkgs.zed-editor` package install and the `zed-lsp.nix` import from this file.
  - The resulting `zed.nix` becomes a pure config-sync module: defines `extensions.zed` options, runs `zedResetConfig` activation to copy settings/keymap files. No packages.
  - In `home/profiles/gui.nix`: import `zed.nix` (for config sync) AND add `pkgs.zed-editor` to packages AND import `zed-lsp.nix` (for LSP servers). gui.nix is only used by PC.
  - This way:
    - PC imports gui.nix → gets Zed package + LSP + config sync
    - Macbook imports zed.nix directly → gets config sync only (Zed binary from Homebrew)
    - VM imports zed-lsp.nix directly → gets LSP servers only (no Zed GUI, no config sync)
  - Build-verify all 3 configs

  **Must NOT do**:
  - Do NOT change the `extensions.zed` option definitions or the activation script logic
  - Do NOT change zed-settings.json or zed-keymap.json
  - Do NOT rename zed.nix (it's the config module, it keeps the name)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Splitting one file's concerns — small surgical edit
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 3)
  - **Blocks**: Task 5
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `home/programs/zed.nix:1-50` — Full current file: options + package + activation + zed-lsp import
  - `home/programs/zed-lsp.nix:1-11` — LSP servers (nil, nixd, rust-analyzer, markdown-oxide, package-version-server)
  - `home/profiles/gui.nix:1-17` — Current gui profile that imports zed.nix
  - `home/users/chase/macbook.nix:16-19` — Uses extensions.zed options (must keep working)
  - `home/users/chase/pc.nix:22-25` — Uses extensions.zed options (must keep working)

  **Acceptance Criteria**:

  ```
  Scenario: zed.nix is config-sync only (no packages)
    Tool: Bash
    Steps:
      1. grep -c 'pkgs.zed-editor' home/programs/zed.nix → Assert: 0
      2. grep -c 'zed-lsp' home/programs/zed.nix → Assert: 0
      3. grep -c 'extensions.zed' home/programs/zed.nix → Assert: >= 1
      4. grep -c 'zedResetConfig' home/programs/zed.nix → Assert: >= 1
    Expected Result: zed.nix only has config sync, no packages

  Scenario: gui.nix has Zed package and LSP
    Tool: Bash
    Steps:
      1. grep -c 'zed-editor' home/profiles/gui.nix → Assert: >= 1
      2. grep -c 'zed-lsp' home/profiles/gui.nix → Assert: >= 1
    Expected Result: gui.nix bundles the package and LSP servers

  Scenario: All 3 configs still build
    Tool: Bash
    Steps:
      1. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      2. nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      3. nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
    Expected Result: All builds pass
  ```

  **Commit**: YES
  - Message: `refactor: split zed.nix into config-sync (shared) and package install (gui-only)`
  - Files: `home/programs/zed.nix`, `home/profiles/gui.nix`
  - Pre-commit: `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run`

---

- [x] 5. Restructure macbook profile composition

  **What to do**:
  - Edit `home/users/chase/macbook.nix` to have the correct imports:
    - KEEP: `../../profiles/base.nix`
    - REMOVE: `../../profiles/development.nix` (macbook is GUI-only, no dev tools)
    - REMOVE: `../../profiles/gui.nix` (bundles Zed package + Kitty via Nix, but macbook gets these from Homebrew)
    - ADD: `../../programs/zed.nix` (config sync only — after Task 4 split)
  - Add Kitty config management directly to macbook.nix (since gui.nix is no longer imported):
    ```nix
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      extraConfig = ''
        window_margin_width 10
        font_size 18.0
      '';
    };
    ```
    This writes `~/.config/kitty/kitty.conf` via home-manager — works regardless of whether Kitty binary comes from Nix or Homebrew.
  - Remove `pkgs.opencode` from macbook.nix home.packages (now in development.nix, which macbook doesn't import — but wait, user wants opencode on macbook too). Actually, `opencode` goes to development.nix in Task 3, which macbook WON'T import. So if user wants opencode on macbook, keep it in macbook.nix. **Clarification**: User said opencode should be on the VM. It's already on macbook. Keep `pkgs.opencode` in macbook.nix since macbook runs it as a GUI tool connecting to the VM.
  - The final macbook.nix imports should be:
    ```
    ../../profiles/base.nix
    ../../programs/zed.nix
    ```
  - Build-verify all 3 configs
  - Verify macbook has NO dev packages

  **Must NOT do**:
  - Do NOT remove `extensions.zed` settings from macbook.nix (still needed for config sync)
  - Do NOT remove `home.shellAliases` (macbook-specific rebuild command)
  - Do NOT change stateVersion

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Editing imports and moving a small config block
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 6, 7)
  - **Blocks**: None
  - **Blocked By**: Tasks 2, 3, 4

  **References**:

  **Pattern References**:
  - `home/users/chase/macbook.nix:1-32` — Current macbook user config (full file)
  - `home/profiles/gui.nix:8-16` — Kitty config block to copy into macbook.nix
  - `home/programs/zed.nix` — After Task 4 split, this is config-sync only

  **Acceptance Criteria**:

  ```
  Scenario: Macbook has correct imports
    Tool: Bash
    Steps:
      1. grep -c 'development.nix' home/users/chase/macbook.nix → Assert: 0
      2. grep -c 'gui.nix' home/users/chase/macbook.nix → Assert: 0
      3. grep -c 'base.nix' home/users/chase/macbook.nix → Assert: 1
      4. grep -c 'zed.nix' home/users/chase/macbook.nix → Assert: 1
    Expected Result: Only base + zed config sync imported

  Scenario: Macbook has NO dev packages
    Tool: Bash
    Steps:
      1. nix eval .#darwinConfigurations.macbook.config.home-manager.users.chase.home.packages --apply 'map (p: p.name)' 2>&1 | grep -cE 'nodejs|bun|pnpm|rust|^go-|gnumake|gcc|mold|solana|codex|pyenv|nil$|nixd|rust-analyzer|markdown-oxide|package-version-server' → Assert: 0
    Expected Result: Zero dev packages on macbook

  Scenario: Macbook still has Zed config sync and Kitty config
    Tool: Bash
    Steps:
      1. grep -c 'zedResetConfig\|extensions.zed' home/users/chase/macbook.nix → Assert: >= 1
      2. grep -c 'programs.kitty' home/users/chase/macbook.nix → Assert: >= 1
    Expected Result: Config management preserved

  Scenario: All 3 configs still build
    Tool: Bash
    Steps:
      1. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      2. nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      3. nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
    Expected Result: All builds pass
  ```

  **Commit**: YES
  - Message: `fix: macbook profile composition — remove dev tools, keep config sync only`
  - Files: `home/users/chase/macbook.nix`
  - Pre-commit: `nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run`

---

- [x] 6. Clean up PC and VM user configs

  **What to do**:
  - **pc.nix**: After Task 3 consolidated dev packages, verify pc.nix only has PC-specific packages remaining:
    - `pkgs.pavucontrol`, `pkgs.vesktop`, `pkgs.slack`, `pkgs.spotify`
    - `pkgs.jetbrains.datagrip`, `pkgs.jetbrains.goland`
    - `pkgs.prismlauncher`, `pkgs.openjdk25`, `pkgs.glfw`
    - `pkgs.obsidian`, `pkgs.audacity`
    - `pkgs.telegram-desktop`, `pkgs.signal-desktop`
    - `pkgs.anki-bin`
  - Remove the `home.sessionVariables.PKG_CONFIG_PATH` from pc.nix if not already removed in Task 3
  - Remove `programs.pyenv.enable` from pc.nix if not already removed in Task 3
  - Remove `../../programs/solana.nix` import from pc.nix if not already removed in Task 3
  - **macbook-vm.nix**: After Task 3 consolidated dev packages, verify macbook-vm.nix only has VM-specific config:
    - Imports: `base.nix`, `development.nix`, `zed-lsp.nix`
    - Shell aliases (vm-specific rebuild command)
    - No packages list (everything moved to development.nix)
  - Verify `opencode` is now available on VM via development.nix
  - Build-verify all 3 configs

  **Must NOT do**:
  - Do NOT remove PC-only packages listed above
  - Do NOT change shell aliases (host-specific rebuild commands)
  - Do NOT change stateVersion

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Verification and minor cleanup of what Task 3 should have handled
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 5, 7)
  - **Blocks**: None
  - **Blocked By**: Tasks 2, 3

  **References**:

  **Pattern References**:
  - `home/users/chase/pc.nix:1-64` — PC user config (post-Task 3 state)
  - `home/users/chase/macbook-vm.nix:1-43` — VM user config (post-Task 3 state)

  **Acceptance Criteria**:

  ```
  Scenario: No duplicated dev packages in user configs
    Tool: Bash
    Steps:
      1. grep -c 'pkgs.gcc\|pkgs.mold\|pkgs.openssl\|pkg-config\|pkgs.solc\|codex-cli\|PKG_CONFIG_PATH\|pyenv' home/users/chase/pc.nix → Assert: 0
      2. grep -c 'pkgs.gcc\|pkgs.mold\|pkgs.openssl\|pkg-config\|pkgs.solc\|codex-cli\|PKG_CONFIG_PATH\|pyenv' home/users/chase/macbook-vm.nix → Assert: 0
    Expected Result: Dev tools only in development.nix

  Scenario: VM has opencode
    Tool: Bash
    Steps:
      1. nix eval .#nixosConfigurations.macbook-vm.config.home-manager.users.chase.home.packages --apply 'map (p: p.name)' 2>&1 | grep -c 'opencode' → Assert: >= 1
    Expected Result: opencode available on VM

  Scenario: All 3 configs still build
    Tool: Bash
    Steps:
      1. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      2. nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      3. nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
    Expected Result: All builds pass
  ```

  **Commit**: YES (group with Task 5 if convenient)
  - Message: `refactor: clean PC and VM user configs after dev package consolidation`
  - Files: `home/users/chase/pc.nix`, `home/users/chase/macbook-vm.nix`
  - Pre-commit: `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run`

---

- [x] 7. Deduplicate flake.nix overlays and final cleanup

  **What to do**:
  - In `flake.nix`, extract the repeated overlay block into a `let` binding:
    ```nix
    let
      commonOverlays = {
        nixpkgs.overlays = [
          rust-overlay.overlays.default
          foundry.overlay  # Remove this line if Task 1 confirmed foundry is unused
        ];
      };
    in
    ```
  - Replace all 3 inline overlay blocks with `commonOverlays`
  - If Task 1 confirmed `foundry` is unused: also remove the `foundry` input from `flake.nix` inputs and remove `foundry` from the outputs function args
  - If Task 1 confirmed `foundry` IS used: keep it, just deduplicate
  - Run `nix flake lock` if inputs were removed
  - Build-verify all 3 configs
  - Final full audit: run `grep -r 'TODO\|FIXME\|HACK' --include="*.nix" .` to check for any remaining tech debt markers

  **Must NOT do**:
  - Do NOT change any functional behavior — this is purely cosmetic deduplication
  - Do NOT remove rust-overlay (it's actively used in development.nix for Rust nightly)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Simple let-binding extraction in flake.nix
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 5, 6)
  - **Blocks**: None
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `flake.nix:73-118` — All 3 output configurations with repeated overlay blocks
  - `flake.nix:46-49` — rust-overlay input
  - `flake.nix:57` — foundry input

  **Acceptance Criteria**:

  ```
  Scenario: Overlays deduplicated
    Tool: Bash
    Steps:
      1. grep -c 'nixpkgs.overlays' flake.nix → Assert: 1 (defined once in let binding)
      2. grep -c 'commonOverlays' flake.nix → Assert: >= 3 (used in all 3 configs)
    Expected Result: Single overlay definition, referenced 3 times

  Scenario: All 3 configs still build
    Tool: Bash
    Steps:
      1. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      2. nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
      3. nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1 → Assert: no errors
    Expected Result: All builds pass
  ```

  **Commit**: YES
  - Message: `refactor: deduplicate flake.nix overlay blocks`
  - Files: `flake.nix`, possibly `flake.lock` if foundry input removed
  - Pre-commit: `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run`

---

## Commit Strategy

| After Task | Message | Key Files | Verification |
|------------|---------|-----------|--------------|
| 1 | `chore: remove dead weight (unused inputs, empty dirs, stale plan.md)` | flake.nix, flake.lock, deleted files | nix build --dry-run (all 3) |
| 2 | `refactor: extract shared NixOS settings into modules/nixos/base.nix` | modules/nixos/base.nix, hosts/pc/default.nix, hosts/macbook-vm/default.nix | nix build --dry-run (all 3) |
| 3 | `refactor: consolidate dev packages into development.nix profile` | home/profiles/development.nix, home/users/chase/{pc,macbook-vm}.nix | nix build --dry-run (all 3) |
| 4 | `refactor: split zed.nix into config-sync and package install` | home/programs/zed.nix, home/profiles/gui.nix | nix build --dry-run (all 3) |
| 5 | `fix: macbook profile — remove dev tools, keep config sync only` | home/users/chase/macbook.nix | nix build --dry-run (all 3) |
| 6 | `refactor: clean PC and VM configs after consolidation` | home/users/chase/{pc,macbook-vm}.nix | nix build --dry-run (all 3) |
| 7 | `refactor: deduplicate flake.nix overlay blocks` | flake.nix | nix build --dry-run (all 3) |

---

## Success Criteria

### Final Environment Matrix (After All Tasks)

| Environment | Profile Imports | Gets |
|---|---|---|
| PC | base + development + gui + hyprland | Everything: CLI tools, dev tools, Zed+LSP, Kitty, Hyprland desktop |
| Macbook | base + zed-config-only | CLI tools + Zed config sync + Kitty config. GUI apps from Homebrew. |
| VM | base + development + zed-lsp | CLI tools, dev tools, LSP servers for remote Zed. No GUI. |

### Verification Commands
```bash
# All 3 must pass:
nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run
nix build .#darwinConfigurations.macbook.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run

# Macbook has no dev packages:
nix eval .#darwinConfigurations.macbook.config.home-manager.users.chase.home.packages --apply 'map (p: p.name)' 2>&1 | grep -cE 'nodejs|bun|pnpm|rust|^go-|gnumake|gcc|mold'
# Expected: 0

# No duplication:
grep -c 'pkgs.gcc\|pkgs.mold\|pkgs.openssl\|pkg-config\|pkgs.solc' home/users/chase/pc.nix home/users/chase/macbook-vm.nix
# Expected: 0 for both

# No dead inputs:
grep -c 'browser-previews\|prismlauncher' flake.nix
# Expected: 0
```

### Final Checklist
- [x] All 3 configs build successfully
- [x] Macbook: zero dev packages, has Zed config sync + Kitty config
- [x] VM: has all dev tools + opencode + LSP servers
- [x] PC: has everything (dev + GUI + Hyprland)
- [x] No duplicated package declarations across user configs
- [x] No duplicated NixOS settings across host configs
- [x] No dead files, directories, or flake inputs
- [x] flake.nix overlay defined once, used three times
- [x] All stateVersion values unchanged
- [x] orbstack.nix untouched
- [x] hyprland/ subtree untouched
