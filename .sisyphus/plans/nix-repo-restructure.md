# NixOS Repo Restructure

## TL;DR

> **Quick Summary**: Reorganize the `.nixconf` NixOS flake repository — flatten the home layer, extract darwin modules, move hyprland to a desktop directory, and decompose the confused `gui.nix` profile — so the repo is clean, symmetric, and easy to navigate across all 3 machines.
> 
> **Deliverables**:
> - New `modules/darwin/` directory with extracted macbook system modules
> - New `home/desktop/hyprland/` directory (moved from programs/)
> - Flattened `home/programs/` (profiles/ merged in, gui.nix decomposed)
> - All 3 machine configs building identically to before
> 
> **Estimated Effort**: Medium
> **Parallel Execution**: YES — 3 waves
> **Critical Path**: Task 1 (scaffold) → Tasks 2-7 (parallel moves) → Task 8 (cleanup) → Task 9 (verify)

---

## Context

### Original Request
Reorganize the NixOS config repo for 3 machines (pc, macbook, macbook-vm) to be organized, simple, and not scatter configs all over the place.

### Interview Summary
**Key Discussions**:
- `extensions.*` custom option pattern: KEEP as-is (no code changes to module internals)
- `solana.nix` orphan: KEEP for future use, leave unimported
- Darwin modules: EXTRACT from macbook host into `modules/darwin/`
- Static config files: KEEP in `users/chase/`
- Validation: Manual rebuild only, no new CI
- `gui.nix`: DELETE and decompose (kitty → hyprland desktop, zed → pc.nix direct)
- Hyprland: MOVE to `home/desktop/hyprland/`
- Profiles layer: FLATTEN into programs/

### Metis Review
**Identified Gaps** (addressed):
- gui.nix deletion silently drops `pkgs.zed-editor` from PC → plan explicitly adds it to pc.nix
- gui.nix deletion breaks zed.nix import chain for PC → plan adds direct import to pc.nix
- Internal import paths in base.nix/development.nix break on move → plan enumerates every path change
- "Refine extensions.*" is vague scope creep risk → locked down: NO code changes, just file organization
- Darwin extraction depth unspecified → plan specifies exact split (base.nix vs homebrew.nix vs host-stays)
- Kitty config in hyprland/ is new content creation, not a move → plan specifies exact attrs to reproduce
- `home-manager.backupFileExtension` is darwin-only → stays in `modules/darwin/base.nix`

---

## Work Objectives

### Core Objective
Restructure the repository's file organization so the directory tree clearly communicates intent — system modules are symmetric across platforms, home-manager config has a flat and obvious hierarchy, and the desktop environment has its own directory — all without changing any system behavior.

### Concrete Deliverables
- `modules/darwin/base.nix` — extracted from hosts/macbook/default.nix
- `modules/darwin/homebrew.nix` — extracted from hosts/macbook/default.nix
- `home/desktop/hyprland/` — moved from home/programs/hyprland/
- `home/programs/base.nix` — moved from home/profiles/base.nix (paths updated)
- `home/programs/development.nix` — moved from home/profiles/development.nix (paths updated)
- Updated imports in pc.nix, macbook.nix, macbook-vm.nix, hosts/macbook/default.nix
- Deleted: `home/profiles/` directory, `home/profiles/gui.nix`

### Definition of Done
- [ ] `nix build .#nixosConfigurations.pc.config.system.build.toplevel --no-link --dry-run` succeeds
- [ ] `nix build .#darwinConfigurations.macbook.system --no-link --dry-run` succeeds
- [ ] `nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-link --dry-run` succeeds
- [ ] No references to `profiles/` remain in any .nix file
- [ ] No references to `programs/hyprland` remain in user configs
- [ ] No reference to `gui.nix` remains anywhere
- [ ] `modules/darwin/` directory exists with base.nix and homebrew.nix
- [ ] `home/desktop/hyprland/` directory exists with all 12 files
- [ ] `home/profiles/` directory no longer exists
- [ ] `pkgs.zed-editor` is still in PC's home packages (verified via nix eval or manual check)
- [ ] `programs.kitty` is still enabled for both PC and macbook

### Must Have
- Zero behavioral changes — all 3 machines produce identical system closures before and after
- Every import path updated correctly — no stale references
- `pkgs.zed-editor` explicitly preserved in PC config after gui.nix deletion
- `programs.kitty` preserved for both PC (via hyprland desktop) and macbook (via macbook.nix)
- Symmetric module structure: `modules/nixos/` and `modules/darwin/` both exist
- Hyprland directory moved atomically (all 12 files + wallpaper.jpg + screenshot.sh)

### Must NOT Have (Guardrails)
- **NO content changes** to any module that is merely being moved (byte-identical except import paths)
- **NO reformatting, reordering attributes, renaming variables, or adding comments** during moves
- **NO changes to modules/nixos/** — all 10 NixOS modules are untouched
- **NO changes to flake.nix** — inputs and outputs structure stays identical
- **NO changes to .github/workflows/** — CI stays as-is
- **NO changes to flake.lock** — no input updates
- **NO changes to static config files** (.json, .toml, .jsonc, .jpg, .sh, .zsh-theme)
- **NO "helpful" imports of solana.nix** — it stays orphaned intentionally
- **NO removal of flake inputs** (even solana-nix which is only used by orphaned module)
- **NO merging/unifying** kitty configs between PC and macbook — they are intentionally different
- **NO changes to hosts/pc/hardware-configuration.nix** or hosts/macbook-vm/orbstack.nix
- **NO changes to the internal structure of hyprland/** files (just move the directory), **EXCEPT** the intentional addition of kitty config to `hyprland/default.nix` in Task 4
- **NO modifications to extensions.* option module internals** (zed.nix, aerospace.nix, opencode.nix, wallpaper.nix)

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: NO (Nix config repo — no test framework)
- **Automated tests**: None (Nix evaluation IS the test)
- **Framework**: `nix build --dry-run` for evaluation verification

### QA Policy
Every task includes agent-executed verification via `nix` CLI commands.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

| Deliverable Type | Verification Tool | Method |
|------------------|-------------------|--------|
| Nix module moves | Bash (nix eval/build) | Evaluate configs, verify no import errors |
| File moves | Bash (test/grep) | Verify old paths removed, new paths exist |
| Import integrity | Bash (grep) | Search for stale references to deleted paths |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Foundation — must complete first):
├── Task 1: Create directory scaffold + darwin module extraction [quick]

Wave 2 (Parallel moves — ALL independent after scaffold):
├── Task 2: Move hyprland/ to home/desktop/ [quick]
├── Task 3: Move base.nix + development.nix from profiles/ to programs/ [quick]
├── Task 4: Decompose gui.nix → update pc.nix [quick]
├── Task 5: Update macbook.nix imports [quick]
├── Task 6: Update macbook-vm.nix imports [quick]
├── Task 7: Slim down hosts/macbook/default.nix to use darwin modules [quick]

Wave 3 (Cleanup + verify — after ALL moves complete):
├── Task 8: Delete old directories and stale files [quick]
├── Task 9: Full verification of all 3 configs [deep]

Wave FINAL (Independent review):
├── Task F1: Plan compliance audit [deep]
├── Task F2: Scope fidelity + stale reference check [deep]
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|------------|--------|------|
| 1 | — | 2, 3, 4, 5, 6, 7 | 1 |
| 2 | 1 | 8 | 2 |
| 3 | 1 | 4, 5, 6, 8 | 2 |
| 4 | 1, 3 | 8 | 2 |
| 5 | 1, 3 | 8 | 2 |
| 6 | 1, 3 | 8 | 2 |
| 7 | 1 | 8 | 2 |
| 8 | 2, 3, 4, 5, 6, 7 | 9 | 3 |
| 9 | 8 | F1, F2 | 3 |
| F1 | 9 | — | FINAL |
| F2 | 9 | — | FINAL |

### Agent Dispatch Summary

| Wave | # Parallel | Tasks → Agent Category |
|------|------------|----------------------|
| 1 | **1** | T1 → `quick` |
| 2 | **6** | T2-T7 → `quick` |
| 3 | **2** | T8 → `quick`, T9 → `deep` |
| FINAL | **2** | F1 → `deep`, F2 → `deep` |

---

## TODOs

- [x] 1. Create directory scaffold + extract darwin modules

  **What to do**:
  - Create `modules/darwin/` directory
  - Create `home/desktop/` directory (add `home/desktop/.gitkeep` to ensure git tracks it before hyprland is moved in)
  - Create `modules/darwin/base.nix` with the following content extracted from `hosts/macbook/default.nix`:
    ```nix
    # Shared Darwin settings
    { pkgs, ... }:
    {
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # System packages
      environment.systemPackages = with pkgs; [
        git
        wget
      ];

      # Enable ZSH
      programs.zsh.enable = true;

      # Home-manager backup strategy (darwin-specific)
      home-manager.backupFileExtension = "hm-backup";
    }
    ```
  - Create `modules/darwin/homebrew.nix` with the following content extracted from `hosts/macbook/default.nix`:
    ```nix
    # Homebrew casks (macOS GUI apps not available via Nix)
    { ... }:
    {
      homebrew = {
        enable = true;
        taps = [
          "nikitabobko/tap"
        ];
        casks = [
          "1password"
          "aerospace"
          "discord"
          "google-chrome"
          "kitty"
          "notion"
          "slack"
          "telegram"
          "zed"
        ];
        onActivation.cleanup = "zap";
      };
    }
    ```

  **Must NOT do**:
  - Do NOT modify any existing files in this task
  - Do NOT create any other directories
  - Do NOT add comments beyond what's shown above

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Creating 2 directories and 2 small .nix files from known content
  - **Skills**: []
    - No special skills needed — pure file creation
  - **Skills Evaluated but Omitted**:
    - `git-master`: No git operations in this task

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 1 (solo)
  - **Blocks**: Tasks 2, 3, 4, 5, 6, 7
  - **Blocked By**: None (can start immediately)

  **References**:

  **Pattern References**:
  - `modules/nixos/base.nix` — The existing NixOS base module. Darwin base should mirror its organizational approach (unfree, shell, system packages) but with darwin-specific content.
  - `hosts/macbook/default.nix:10-17` — Source of truth for what goes into `modules/darwin/base.nix` (lines 10-20: allowUnfree, systemPackages, zsh.enable)
  - `hosts/macbook/default.nix:39-57` — Source of truth for what goes into `modules/darwin/homebrew.nix` (the entire homebrew block)
  - `hosts/macbook/default.nix:33` — The `backupFileExtension = "hm-backup"` line that moves to darwin base

  **Acceptance Criteria**:
  - [ ] `test -d modules/darwin` → directory exists
  - [ ] `test -d home/desktop` → directory exists
  - [ ] `test -f modules/darwin/base.nix` → file exists
  - [ ] `test -f modules/darwin/homebrew.nix` → file exists
  - [ ] `nix-instantiate --parse modules/darwin/base.nix` → valid Nix syntax
  - [ ] `nix-instantiate --parse modules/darwin/homebrew.nix` → valid Nix syntax

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Darwin modules are valid Nix files
    Tool: Bash
    Preconditions: Task 1 file creation complete
    Steps:
      1. Run `nix-instantiate --parse modules/darwin/base.nix`
      2. Run `nix-instantiate --parse modules/darwin/homebrew.nix`
      3. Verify both exit with code 0
    Expected Result: Both files parse as valid Nix expressions
    Failure Indicators: Parse error or non-zero exit code
    Evidence: .sisyphus/evidence/task-1-darwin-modules-parse.txt

  Scenario: Directory scaffold exists
    Tool: Bash
    Preconditions: Task 1 complete
    Steps:
      1. Run `test -d modules/darwin && test -d home/desktop && echo PASS || echo FAIL`
    Expected Result: "PASS"
    Failure Indicators: "FAIL" or directory not found
    Evidence: .sisyphus/evidence/task-1-scaffold-dirs.txt
  ```

  **Commit**: YES
  - Message: `refactor(modules): extract darwin modules and create directory scaffold`
  - Files: `modules/darwin/base.nix`, `modules/darwin/homebrew.nix`, `home/desktop/.gitkeep`
  - Pre-commit: `nix-instantiate --parse modules/darwin/base.nix && nix-instantiate --parse modules/darwin/homebrew.nix`

---

- [x] 2. Move hyprland/ directory from programs/ to desktop/

  **What to do**:
  - Move the ENTIRE `home/programs/hyprland/` directory to `home/desktop/hyprland/`
  - This includes ALL 12 items:
    - `default.nix`, `flux.nix`, `keybindings.nix`, `launcher.nix`, `lock.nix`, `notifications.nix`, `screenshot.nix`, `screenshot.sh`, `theme.nix`, `wallpaper.jpg`, `wallpaper.nix`, `windowrules.nix`
  - Remove `home/desktop/.gitkeep` after moving hyprland in (it's no longer needed)
  - **ZERO content changes** — all files byte-identical after move
  - Internal imports within hyprland/ all use `./` relative paths, so they don't change

  **Must NOT do**:
  - Do NOT modify any file content — this is a pure directory move
  - Do NOT update import references in other files (that's Task 4)
  - Do NOT reformat or reorder anything
  - Do NOT touch the old `home/programs/` directory (deletion is Task 8)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Pure `mv` operation for a directory
  - **Skills**: []
    - No special skills needed — file system operation only
  - **Skills Evaluated but Omitted**:
    - `git-master`: Just a mv, not a git-specific operation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3, 4, 5, 6, 7)
  - **Blocks**: Task 8
  - **Blocked By**: Task 1 (needs `home/desktop/` directory to exist)

  **References**:

  **Source directory**:
  - `home/programs/hyprland/` — All 14 items to move, listed above

  **Internal import integrity**:
  - `home/programs/hyprland/default.nix:14-26` — Imports `./keybindings.nix`, `./windowrules.nix`, `./theme.nix`, `./screenshot.nix`, `./lock.nix`, `./notifications.nix`, `./launcher.nix`, `./wallpaper.nix`, `./flux.nix` — all `./` relative, so they survive the move unchanged
  - `home/programs/hyprland/screenshot.nix:10` — References `./screenshot.sh` — survives move unchanged
  - `home/programs/hyprland/default.nix:29` — References `./wallpaper.jpg` — survives move unchanged

  **Acceptance Criteria**:
  - [ ] `test -d home/desktop/hyprland` → directory exists
  - [ ] `ls home/desktop/hyprland/ | wc -l` → 12 (all items present)

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: All 12 hyprland items exist in new location
    Tool: Bash
    Preconditions: home/desktop/ directory exists from Task 1
    Steps:
      1. Run `ls home/desktop/hyprland/` and capture output
      2. Verify all 12 expected items are present: default.nix, flux.nix, keybindings.nix, launcher.nix, lock.nix, notifications.nix, screenshot.nix, screenshot.sh, theme.nix, wallpaper.jpg, wallpaper.nix, windowrules.nix
      3. Run `nix-instantiate --parse home/desktop/hyprland/default.nix` to verify the entry point parses
    Expected Result: All 12 items present, default.nix parses successfully
    Failure Indicators: Missing files or parse error
    Evidence: .sisyphus/evidence/task-2-hyprland-move.txt

  Scenario: No content changes during move
    Tool: Bash
    Preconditions: Move complete
    Steps:
      1. Run `git diff --stat` on the hyprland files
      2. Verify all changes show as "rename" with 100% similarity, not content modifications
    Expected Result: All files show as renames with 100% similarity index
    Failure Indicators: Any file showing content modifications (non-100% similarity)
    Evidence: .sisyphus/evidence/task-2-hyprland-no-content-change.txt
  ```

  **Commit**: YES (groups with Tasks 3-7 if desired, or standalone)
  - Message: `refactor(home): move hyprland desktop environment to home/desktop/`
  - Files: `home/desktop/hyprland/*` (added), `home/programs/hyprland/*` (removed)
  - Pre-commit: `nix-instantiate --parse home/desktop/hyprland/default.nix`

---

- [x] 3. Move base.nix and development.nix from profiles/ to programs/

  **What to do**:
  - Move `home/profiles/base.nix` → `home/programs/base.nix`
  - Move `home/profiles/development.nix` → `home/programs/development.nix`
  - **Update internal import paths** in both files (this is a content change):

  **base.nix import path changes**:
  ```
  BEFORE: ../programs/opencode.nix  →  AFTER: ./opencode.nix
  BEFORE: ../programs/zsh.nix       →  AFTER: ./zsh.nix
  ```

  **development.nix import path changes**:
  ```
  BEFORE: ../programs/language-servers.nix  →  AFTER: ./language-servers.nix
  ```

  - NO other content changes beyond these import paths

  **Must NOT do**:
  - Do NOT update references in user configs (pc.nix, macbook.nix, macbook-vm.nix) — that's Tasks 4-6
  - Do NOT reformat, reorder, or change any other content
  - Do NOT delete `home/profiles/` directory — that's Task 8
  - Do NOT touch `home/profiles/gui.nix` — that's Task 4/8

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Move 2 files and update 3 import paths — simple string replacements
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `git-master`: Not needed for file moves with edits

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 2, 7)
  - **Parallel Group**: Wave 2
  - **Blocks**: Tasks 4, 5, 6, 8
  - **Blocked By**: Task 1

  **References**:

  **Files being moved**:
  - `home/profiles/base.nix` — Full file content (37 lines). Line 5-6 have the imports to update: `../programs/opencode.nix` and `../programs/zsh.nix`
  - `home/profiles/development.nix` — Full file content (43 lines). Line 5 has the import to update: `../programs/language-servers.nix`

  **Import path logic**:
  - These files currently live in `home/profiles/` and reference siblings in `home/programs/` via `../programs/X.nix`
  - After moving INTO `home/programs/`, the sibling references become `./X.nix`

  **Acceptance Criteria**:
  - [ ] `test -f home/programs/base.nix` → file exists
  - [ ] `test -f home/programs/development.nix` → file exists
  - [ ] `grep -c '\./opencode.nix' home/programs/base.nix` → 1 (updated path)
  - [ ] `grep -c '\./zsh.nix' home/programs/base.nix` → 1 (updated path)
  - [ ] `grep -c '\./language-servers.nix' home/programs/development.nix` → 1 (updated path)
  - [ ] `grep -c '\.\./programs/' home/programs/base.nix` → 0 (no stale paths)
  - [ ] `grep -c '\.\./programs/' home/programs/development.nix` → 0 (no stale paths)
  - [ ] `nix-instantiate --parse home/programs/base.nix` → valid syntax
  - [ ] `nix-instantiate --parse home/programs/development.nix` → valid syntax

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Import paths correctly updated in base.nix
    Tool: Bash
    Preconditions: Files moved to home/programs/
    Steps:
      1. Run `grep 'opencode.nix' home/programs/base.nix` — expect `./opencode.nix`
      2. Run `grep 'zsh.nix' home/programs/base.nix` — expect `./zsh.nix`
      3. Run `grep '../programs/' home/programs/base.nix` — expect NO matches (stale paths)
      4. Run `nix-instantiate --parse home/programs/base.nix`
    Expected Result: Updated paths found, no stale paths, valid Nix syntax
    Failure Indicators: Old `../programs/` paths still present, or parse failure
    Evidence: .sisyphus/evidence/task-3-base-imports.txt

  Scenario: Import paths correctly updated in development.nix
    Tool: Bash
    Preconditions: Files moved to home/programs/
    Steps:
      1. Run `grep 'language-servers.nix' home/programs/development.nix` — expect `./language-servers.nix`
      2. Run `grep '../programs/' home/programs/development.nix` — expect NO matches
      3. Run `nix-instantiate --parse home/programs/development.nix`
    Expected Result: Updated path found, no stale paths, valid Nix syntax
    Failure Indicators: Old path still present, or parse failure
    Evidence: .sisyphus/evidence/task-3-development-imports.txt
  ```

  **Commit**: YES (groups with Task 2)
  - Message: `refactor(home): flatten profiles into programs directory`
  - Files: `home/programs/base.nix` (added), `home/programs/development.nix` (added), `home/profiles/base.nix` (removed), `home/profiles/development.nix` (removed)
  - Pre-commit: `nix-instantiate --parse home/programs/base.nix && nix-instantiate --parse home/programs/development.nix`

---

- [x] 4. Decompose gui.nix and update pc.nix

  **What to do**:
  This is the most complex task — gui.nix is being deleted and its responsibilities redistributed.

  **gui.nix currently provides 3 things to PC:**
  1. `imports = [ ../programs/zed.nix ]` — zed activation module
  2. `pkgs.zed-editor` in home.packages — the zed binary
  3. `programs.kitty = { enable = true; ... }` — kitty terminal config

  **Redistribution:**
  - **zed.nix import** → add directly to `home/users/chase/pc.nix` imports
  - **pkgs.zed-editor** → add to `home/users/chase/pc.nix` home.packages
  - **kitty config** → add to `home/desktop/hyprland/default.nix` (PC's desktop environment)

  **Step 1: Update `home/users/chase/pc.nix`**:
  
  Change imports from:
  ```nix
  imports = [
    ../../profiles/base.nix
    ../../profiles/development.nix
    ../../profiles/gui.nix
    ../../programs/hyprland
  ];
  ```
  To:
  ```nix
  imports = [
    ../../programs/base.nix
    ../../programs/development.nix
    ../../programs/zed.nix
    ../../desktop/hyprland
  ];
  ```

  Add `pkgs.zed-editor` to the existing `home.packages` list:
  ```nix
  home.packages = [
    pkgs.zed-editor    # Was provided by gui.nix
    pkgs.pavucontrol
    # ... rest unchanged
  ];
  ```

  **Step 2: Add kitty config to `home/desktop/hyprland/default.nix`**:
  
  Add the following kitty configuration (exactly reproducing gui.nix's settings):
  ```nix
  # Terminal (kitty)
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    extraConfig = ''
      window_margin_width 10
      font_size 18.0
    '';
  };
  ```
  Add this block to the `config` section of hyprland/default.nix, after the existing content (e.g., after `services.ssh-agent.enable = true;` on line 103).

  **Must NOT do**:
  - Do NOT modify macbook.nix or macbook-vm.nix (those are Tasks 5-6)
  - Do NOT delete gui.nix (that's Task 8)
  - Do NOT modify any other content in pc.nix beyond imports and home.packages
  - Do NOT modify any other content in hyprland/default.nix beyond adding the kitty block
  - Do NOT change the kitty config values — exact reproduction of gui.nix lines 12-19

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 2 file edits with specific, well-defined changes
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `git-master`: Not needed — straightforward edits

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 2, 5, 6, 7) — but MUST wait for Task 3 (needs base.nix/development.nix to be in programs/ for import paths)
  - **Parallel Group**: Wave 2 (runs after Task 3 completes within Wave 2)
  - **Blocks**: Task 8
  - **Blocked By**: Tasks 1, 3

  **References**:

  **Source of truth for gui.nix decomposition**:
  - `home/profiles/gui.nix` — The file being decomposed. Line 5: `../programs/zed.nix` import. Line 9: `pkgs.zed-editor`. Lines 12-19: `programs.kitty` block.

  **Files being modified**:
  - `home/users/chase/pc.nix:4-12` — Current imports block that needs updating. Note: lines 4-12 are the imports array.
  - `home/users/chase/pc.nix:30-45` — Current home.packages list where `pkgs.zed-editor` must be added.
  - `home/desktop/hyprland/default.nix:101-104` — End of config section where kitty block should be added. Currently ends with `programs.google-chrome.enable = true; services.ssh-agent.enable = true;`

  **Kitty config exact reproduction** (from gui.nix):
  - `enable = true` ✓
  - `shellIntegration.enableZshIntegration = true` ✓
  - `extraConfig` with `window_margin_width 10` and `font_size 18.0` ✓
  - That's ALL — gui.nix has no other kitty settings

  **What macbook's kitty looks like** (for contrast — DO NOT use this):
  - `home/users/chase/macbook.nix:36-48` — Different kitty config with macOS-specific settings (package = emptyDirectory, titlebar-only, opacity, quit behavior). This must NOT be touched or unified.

  **Acceptance Criteria**:
  - [ ] pc.nix imports: `../../programs/base.nix`, `../../programs/development.nix`, `../../programs/zed.nix`, `../../desktop/hyprland`
  - [ ] pc.nix does NOT import `../../profiles/gui.nix` or `../../profiles/base.nix` or `../../profiles/development.nix` or `../../programs/hyprland`
  - [ ] `pkgs.zed-editor` is in pc.nix's home.packages
  - [ ] hyprland/default.nix contains `programs.kitty.enable = true`
  - [ ] hyprland/default.nix contains `shellIntegration.enableZshIntegration = true`
  - [ ] hyprland/default.nix contains `window_margin_width 10` and `font_size 18.0`
  - [ ] `nix-instantiate --parse home/users/chase/pc.nix` → valid syntax
  - [ ] `nix-instantiate --parse home/desktop/hyprland/default.nix` → valid syntax

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: pc.nix imports are correct after gui.nix decomposition
    Tool: Bash
    Preconditions: pc.nix edited, Task 3 complete (files in programs/)
    Steps:
      1. Run `grep 'profiles/' home/users/chase/pc.nix` — expect NO matches
      2. Run `grep 'programs/hyprland' home/users/chase/pc.nix` — expect NO matches
      3. Run `grep 'gui.nix' home/users/chase/pc.nix` — expect NO matches
      4. Run `grep 'programs/base.nix' home/users/chase/pc.nix` — expect 1 match
      5. Run `grep 'programs/development.nix' home/users/chase/pc.nix` — expect 1 match
      6. Run `grep 'programs/zed.nix' home/users/chase/pc.nix` — expect 1 match
      7. Run `grep 'desktop/hyprland' home/users/chase/pc.nix` — expect 1 match
      8. Run `grep 'zed-editor' home/users/chase/pc.nix` — expect 1 match (in home.packages)
    Expected Result: No stale paths, all new paths present, zed-editor in packages
    Failure Indicators: Any stale path found, or new paths missing
    Evidence: .sisyphus/evidence/task-4-pc-imports.txt

  Scenario: Kitty config correctly added to hyprland desktop
    Tool: Bash
    Preconditions: hyprland/default.nix edited
    Steps:
      1. Run `grep 'programs.kitty' home/desktop/hyprland/default.nix` — expect matches
      2. Run `grep 'window_margin_width 10' home/desktop/hyprland/default.nix` — expect 1 match
      3. Run `grep 'font_size 18.0' home/desktop/hyprland/default.nix` — expect 1 match
      4. Run `nix-instantiate --parse home/desktop/hyprland/default.nix`
    Expected Result: Kitty config present with exact values from gui.nix, valid syntax
    Failure Indicators: Missing kitty config, wrong values, or parse failure
    Evidence: .sisyphus/evidence/task-4-kitty-in-hyprland.txt
  ```

  **Commit**: YES
  - Message: `refactor(home): decompose gui.nix into pc.nix and hyprland desktop`
  - Files: `home/users/chase/pc.nix`, `home/desktop/hyprland/default.nix`
  - Pre-commit: `nix-instantiate --parse home/users/chase/pc.nix && nix-instantiate --parse home/desktop/hyprland/default.nix`

---

- [x] 5. Update macbook.nix imports

  **What to do**:
  - Update `home/users/chase/macbook.nix` import paths from profiles/ to programs/:

  Change imports from:
  ```nix
  imports = [
    ../../profiles/base.nix
    ../../profiles/development.nix
    ../../programs/zed.nix
    ../../programs/aerospace.nix
  ];
  ```
  To:
  ```nix
  imports = [
    ../../programs/base.nix
    ../../programs/development.nix
    ../../programs/zed.nix
    ../../programs/aerospace.nix
  ];
  ```

  - Only the first 2 imports change (profiles → programs). The last 2 are already under programs/ and stay unchanged.
  - **ZERO other content changes.**

  **Must NOT do**:
  - Do NOT modify kitty config in macbook.nix — it's intentionally different from PC
  - Do NOT modify home.packages, shellAliases, or anything else
  - Do NOT touch the `package = pkgs.emptyDirectory` hack on line 38

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 2 string replacements in import paths
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 2, 4, 6, 7)
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 8
  - **Blocked By**: Tasks 1, 3

  **References**:

  **File being modified**:
  - `home/users/chase/macbook.nix:4-10` — The imports block. Lines 6-7 change from `../../profiles/` to `../../programs/`. Lines 8-9 stay unchanged.

  **Acceptance Criteria**:
  - [ ] `grep 'profiles/' home/users/chase/macbook.nix` → 0 matches (no stale paths)
  - [ ] `grep 'programs/base.nix' home/users/chase/macbook.nix` → 1 match
  - [ ] `grep 'programs/development.nix' home/users/chase/macbook.nix` → 1 match
  - [ ] `nix-instantiate --parse home/users/chase/macbook.nix` → valid syntax

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: macbook.nix imports updated, no stale paths
    Tool: Bash
    Preconditions: macbook.nix edited
    Steps:
      1. Run `grep 'profiles/' home/users/chase/macbook.nix` — expect NO matches
      2. Run `grep 'programs/base.nix' home/users/chase/macbook.nix` — expect 1 match
      3. Run `grep 'programs/development.nix' home/users/chase/macbook.nix` — expect 1 match
      4. Run `grep 'programs/zed.nix' home/users/chase/macbook.nix` — expect 1 match (unchanged)
      5. Run `grep 'programs/aerospace.nix' home/users/chase/macbook.nix` — expect 1 match (unchanged)
      6. Run `nix-instantiate --parse home/users/chase/macbook.nix`
    Expected Result: All 4 imports point to programs/, valid syntax
    Failure Indicators: Stale profiles/ path or parse failure
    Evidence: .sisyphus/evidence/task-5-macbook-imports.txt

  Scenario: macbook.nix kitty config untouched
    Tool: Bash
    Preconditions: macbook.nix edited
    Steps:
      1. Run `grep 'emptyDirectory' home/users/chase/macbook.nix` — expect 1 match
      2. Run `grep 'background_opacity' home/users/chase/macbook.nix` — expect 1 match
    Expected Result: macOS-specific kitty config preserved exactly
    Failure Indicators: Missing emptyDirectory or macOS kitty settings
    Evidence: .sisyphus/evidence/task-5-macbook-kitty-preserved.txt
  ```

  **Commit**: YES (groups with Task 6)
  - Message: `refactor(home): update macbook and macbook-vm imports for new paths`
  - Files: `home/users/chase/macbook.nix`
  - Pre-commit: `nix-instantiate --parse home/users/chase/macbook.nix`

---

- [x] 6. Update macbook-vm.nix imports

  **What to do**:
  - Update `home/users/chase/macbook-vm.nix` import paths from profiles/ to programs/:

  Change imports from:
  ```nix
  imports = [
    ../../profiles/base.nix
    ../../profiles/development.nix
  ];
  ```
  To:
  ```nix
  imports = [
    ../../programs/base.nix
    ../../programs/development.nix
  ];
  ```

  - **ZERO other content changes.**

  **Must NOT do**:
  - Do NOT modify any other content in the file
  - Do NOT add or remove any imports beyond updating these paths

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 2 string replacements in import paths
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 2, 4, 5, 7)
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 8
  - **Blocked By**: Tasks 1, 3

  **References**:

  **File being modified**:
  - `home/users/chase/macbook-vm.nix:8-12` — The imports block. Both lines change from `../../profiles/` to `../../programs/`.

  **Acceptance Criteria**:
  - [ ] `grep 'profiles/' home/users/chase/macbook-vm.nix` → 0 matches
  - [ ] `grep 'programs/base.nix' home/users/chase/macbook-vm.nix` → 1 match
  - [ ] `grep 'programs/development.nix' home/users/chase/macbook-vm.nix` → 1 match
  - [ ] `nix-instantiate --parse home/users/chase/macbook-vm.nix` → valid syntax

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: macbook-vm.nix imports updated
    Tool: Bash
    Preconditions: macbook-vm.nix edited
    Steps:
      1. Run `grep 'profiles/' home/users/chase/macbook-vm.nix` — expect NO matches
      2. Run `grep 'programs/base.nix' home/users/chase/macbook-vm.nix` — expect 1 match
      3. Run `grep 'programs/development.nix' home/users/chase/macbook-vm.nix` — expect 1 match
      4. Run `nix-instantiate --parse home/users/chase/macbook-vm.nix`
    Expected Result: Updated paths, valid syntax
    Failure Indicators: Stale paths or parse failure
    Evidence: .sisyphus/evidence/task-6-vm-imports.txt
  ```

  **Commit**: YES (groups with Task 5)
  - Message: (grouped with Task 5's commit)
  - Files: `home/users/chase/macbook-vm.nix`
  - Pre-commit: `nix-instantiate --parse home/users/chase/macbook-vm.nix`

---

- [x] 7. Slim down hosts/macbook/default.nix to use darwin modules

  **What to do**:
  - Update `hosts/macbook/default.nix` to import the new darwin modules instead of having inline config
  - Add imports for `../../modules/darwin/base.nix` and `../../modules/darwin/homebrew.nix`
  - Remove the settings that are now in those modules:
    - Remove `nixpkgs.config.allowUnfree = true;` (now in modules/darwin/base.nix)
    - Remove `environment.systemPackages` block (now in modules/darwin/base.nix)
    - Remove `programs.zsh.enable = true;` (now in modules/darwin/base.nix)
    - Remove `home-manager.backupFileExtension` (now in modules/darwin/base.nix)
    - Remove the entire `homebrew = { ... };` block (now in modules/darwin/homebrew.nix)

  **The file after editing should look like:**
  ```nix
  {
    pkgs,
    inputs,
    ...
  }:
  {
    imports = [
      ../../modules/darwin/base.nix
      ../../modules/darwin/homebrew.nix
    ];

    # Determinate Nix custom settings (written to /etc/nix/nix.custom.conf)
    determinateNix.customSettings.trusted-users = [ "root" "chase" "@admin" ];

    # Define user
    users.users.chase = {
      name = "chase";
      home = "/Users/chase";
    };

    # Primary user for system defaults
    system.primaryUser = "chase";

    # Home Manager
    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      useGlobalPkgs = true;
      users.chase = import ../../home/users/chase/macbook.nix;
    };

    # Used for backwards compatibility
    system.stateVersion = 5;
  }
  ```

  **Must NOT do**:
  - Do NOT modify the `determinateNix.customSettings` line — this is host-specific
  - Do NOT modify the `users.users.chase` block — this is host-specific
  - Do NOT modify the `system.primaryUser` line — this is host-specific
  - Do NOT modify the `home-manager` block — this is host-specific
  - Do NOT modify `system.stateVersion` — ALWAYS host-specific
  - Do NOT add anything not shown above

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: One file rewrite — remove extracted inline config, add 2 imports
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 2-6)
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 8
  - **Blocked By**: Task 1 (needs darwin modules to exist)

  **References**:

  **File being modified**:
  - `hosts/macbook/default.nix` — The entire 64-line file. After editing, should be ~30 lines.

  **Darwin modules created in Task 1**:
  - `modules/darwin/base.nix` — Contains the allowUnfree, systemPackages, zsh, and backupFileExtension settings extracted from this file
  - `modules/darwin/homebrew.nix` — Contains the entire homebrew block extracted from this file

  **Acceptance Criteria**:
  - [ ] `grep 'modules/darwin/base.nix' hosts/macbook/default.nix` → 1 match
  - [ ] `grep 'modules/darwin/homebrew.nix' hosts/macbook/default.nix` → 1 match
  - [ ] `grep 'allowUnfree' hosts/macbook/default.nix` → 0 matches (moved to module)
  - [ ] `grep 'homebrew' hosts/macbook/default.nix` → 0 matches (moved to module)
  - [ ] `grep 'environment.systemPackages' hosts/macbook/default.nix` → 0 matches (moved to module)
  - [ ] `grep 'stateVersion' hosts/macbook/default.nix` → 1 match (stays)
  - [ ] `grep 'determinateNix' hosts/macbook/default.nix` → 1 match (stays)
  - [ ] `nix-instantiate --parse hosts/macbook/default.nix` → valid syntax

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: macbook host config slimmed and using darwin modules
    Tool: Bash
    Preconditions: darwin modules created in Task 1, macbook default.nix edited
    Steps:
      1. Run `grep 'modules/darwin/base.nix' hosts/macbook/default.nix` — expect 1 match
      2. Run `grep 'modules/darwin/homebrew.nix' hosts/macbook/default.nix` — expect 1 match
      3. Run `grep 'allowUnfree' hosts/macbook/default.nix` — expect 0 matches
      4. Run `grep 'homebrew' hosts/macbook/default.nix` — expect 0 matches
      5. Run `grep 'stateVersion' hosts/macbook/default.nix` — expect 1 match
      6. Run `wc -l hosts/macbook/default.nix` — expect approximately 30 lines (down from 64)
      7. Run `nix-instantiate --parse hosts/macbook/default.nix`
    Expected Result: Imports present, inline config removed, host-specific settings remain, valid syntax
    Failure Indicators: Extracted settings still inline, missing imports, or parse failure
    Evidence: .sisyphus/evidence/task-7-macbook-slim.txt

  Scenario: No double-definition of extracted settings
    Tool: Bash
    Preconditions: macbook default.nix edited
    Steps:
      1. Run `grep -c 'programs.zsh.enable' hosts/macbook/default.nix` — expect 0
      2. Run `grep -c 'backupFileExtension' hosts/macbook/default.nix` — expect 0
    Expected Result: Settings exist only in modules, not duplicated in host
    Failure Indicators: Settings found in both module and host
    Evidence: .sisyphus/evidence/task-7-no-double-def.txt
  ```

  **Commit**: YES
  - Message: `refactor(darwin): slim macbook host config to use darwin modules`
  - Files: `hosts/macbook/default.nix`
  - Pre-commit: `nix-instantiate --parse hosts/macbook/default.nix`

---

- [x] 8. Delete old directories and stale files

  **What to do**:
  - Delete `home/profiles/gui.nix` (decomposed in Task 4)
  - Delete `home/profiles/base.nix` (moved in Task 3)
  - Delete `home/profiles/development.nix` (moved in Task 3)
  - Delete the now-empty `home/profiles/` directory
  - Delete `home/programs/hyprland/` directory (moved in Task 2)
  - Verify no other files were accidentally left behind

  **Must NOT do**:
  - Do NOT delete `home/programs/solana.nix` — intentionally kept
  - Do NOT delete any file not listed above
  - Do NOT modify any remaining files

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: `rm` operations only
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 3 (sequential after Wave 2)
  - **Blocks**: Task 9
  - **Blocked By**: Tasks 2, 3, 4, 5, 6, 7

  **References**:

  **Files/dirs to delete**:
  - `home/profiles/gui.nix` — decomposed into pc.nix + hyprland/default.nix (Task 4)
  - `home/profiles/base.nix` — moved to `home/programs/base.nix` (Task 3)
  - `home/profiles/development.nix` — moved to `home/programs/development.nix` (Task 3)
  - `home/profiles/` — should be empty after above deletions
  - `home/programs/hyprland/` — moved to `home/desktop/hyprland/` (Task 2)

  **Acceptance Criteria**:
  - [ ] `test ! -d home/profiles` → profiles/ directory gone
  - [ ] `test ! -d home/programs/hyprland` → old hyprland location gone
  - [ ] `test ! -f home/profiles/gui.nix` → gui.nix gone
  - [ ] `test -f home/programs/solana.nix` → solana.nix still exists (NOT deleted)
  - [ ] `test -d home/desktop/hyprland` → hyprland in new location

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Old directories and files removed
    Tool: Bash
    Preconditions: All Wave 2 tasks complete
    Steps:
      1. Run `test ! -d home/profiles && echo PASS || echo FAIL` — expect PASS
      2. Run `test ! -d home/programs/hyprland && echo PASS || echo FAIL` — expect PASS
      3. Run `test -f home/programs/solana.nix && echo PASS || echo FAIL` — expect PASS (preserved)
      4. Run `ls home/programs/` — verify expected files remain
    Expected Result: Old dirs gone, solana preserved, all expected programs/ files present
    Failure Indicators: Old directories still exist, or solana accidentally deleted
    Evidence: .sisyphus/evidence/task-8-cleanup.txt

  Scenario: No stale references to deleted paths in any .nix file
    Tool: Bash
    Preconditions: Cleanup complete
    Steps:
      1. Run `grep -r 'profiles/' home/ hosts/ modules/ --include='*.nix'` — expect 0 matches
      2. Run `grep -r 'programs/hyprland' home/users/ --include='*.nix'` — expect 0 matches
      3. Run `grep -r 'gui\.nix' home/ --include='*.nix'` — expect 0 matches
    Expected Result: Zero stale references anywhere in the codebase
    Failure Indicators: Any match found = dangling import that will break evaluation
    Evidence: .sisyphus/evidence/task-8-no-stale-refs.txt
  ```

  **Commit**: YES
  - Message: `refactor(home): remove old profiles directory and stale files`
  - Files: `home/profiles/` (removed), `home/programs/hyprland/` (removed)
  - Pre-commit: `grep -r 'profiles/' home/ hosts/ modules/ --include='*.nix' && exit 1 || exit 0`

---

- [x] 9. Full verification of all 3 machine configs

  **What to do**:
  - Evaluate all 3 flake outputs to verify they build correctly after restructuring
  - Verify package presence (zed-editor for PC, kitty for PC + macbook)
  - Run structural verification checks
  - This task must be run from a machine with Nix installed (the macbook or macbook-vm)

  **Verification commands**:
  ```bash
  # 1. Evaluate all 3 configs (dry-run — no actual build needed)
  nix build .#nixosConfigurations.pc.config.system.build.toplevel --no-link --dry-run
  nix build .#darwinConfigurations.macbook.system --no-link --dry-run
  nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-link --dry-run

  # 2. Verify kitty is still configured for PC
  nix eval .#nixosConfigurations.pc.config.home-manager.users.chase.programs.kitty.enable
  # Expected: true

  # 3. Verify kitty is still configured for macbook
  nix eval .#darwinConfigurations.macbook.config.home-manager.users.chase.programs.kitty.enable
  # Expected: true

  # 4. Structural checks
  test ! -d home/profiles && echo "PASS: profiles/ removed" || echo "FAIL"
  test -d modules/darwin && echo "PASS: modules/darwin/ exists" || echo "FAIL"
  test -d home/desktop/hyprland && echo "PASS: desktop/hyprland/ exists" || echo "FAIL"
  test ! -d home/programs/hyprland && echo "PASS: old hyprland gone" || echo "FAIL"

  # 5. No stale references
  grep -r 'profiles/' home/ hosts/ modules/ --include='*.nix' && echo "FAIL: stale ref" || echo "PASS: no stale refs"
  ```

  **Must NOT do**:
  - Do NOT modify any files — this is a read-only verification task
  - Do NOT attempt to `nixos-rebuild switch` — that changes the running system

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Must carefully verify all 3 build targets and multiple structural checks
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 3 (after Task 8)
  - **Blocks**: F1, F2
  - **Blocked By**: Task 8

  **References**:

  **Flake outputs to verify**:
  - `flake.nix:72` — `nixosConfigurations.pc`
  - `flake.nix:82` — `darwinConfigurations.macbook`
  - `flake.nix:93` — `nixosConfigurations.macbook-vm`

  **Acceptance Criteria**:
  - [ ] All 3 `nix build --dry-run` commands succeed (exit code 0)
  - [ ] `programs.kitty.enable` evaluates to `true` for PC and macbook
  - [ ] All structural checks pass
  - [ ] Zero stale references found

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: All 3 machine configs evaluate successfully
    Tool: Bash
    Preconditions: All previous tasks complete
    Steps:
      1. Run `nix build .#nixosConfigurations.pc.config.system.build.toplevel --no-link --dry-run 2>&1`
      2. Run `nix build .#darwinConfigurations.macbook.system --no-link --dry-run 2>&1`
      3. Run `nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-link --dry-run 2>&1`
      4. Verify all 3 exit with code 0
    Expected Result: All 3 configs evaluate without errors
    Failure Indicators: Non-zero exit code, "file not found" errors, "undefined variable" errors
    Evidence: .sisyphus/evidence/task-9-build-verification.txt

  Scenario: Critical packages preserved after restructure
    Tool: Bash
    Preconditions: All builds pass
    Steps:
      1. Run `nix eval .#nixosConfigurations.pc.config.home-manager.users.chase.programs.kitty.enable` — expect `true`
      2. Run `nix eval .#darwinConfigurations.macbook.config.home-manager.users.chase.programs.kitty.enable` — expect `true`
    Expected Result: Both return `true`
    Failure Indicators: Returns `false` or evaluation error
    Evidence: .sisyphus/evidence/task-9-package-preservation.txt

  Scenario: Final structural integrity
    Tool: Bash
    Preconditions: All tasks complete
    Steps:
      1. Run `find home/ -name '*.nix' -exec grep -l 'profiles/' {} \;` — expect empty output
      2. Run `find home/users/ -name '*.nix' -exec grep -l 'programs/hyprland' {} \;` — expect empty output
      3. Run `ls modules/darwin/` — expect base.nix and homebrew.nix
      4. Run `ls home/desktop/hyprland/ | wc -l` — expect 12
      5. Run `ls home/programs/` — expect base.nix, development.nix, aerospace.nix, language-servers.nix, main.zsh-theme, opencode.nix, solana.nix, zed.nix, zsh.nix (9 items)
    Expected Result: No stale refs, correct file counts in all directories
    Failure Indicators: Stale references, wrong file counts, missing files
    Evidence: .sisyphus/evidence/task-9-structural-integrity.txt
  ```

  **Commit**: NO (verification only — no changes to commit)

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

> 2 review agents run in PARALLEL. ALL must APPROVE. Rejection → fix → re-run.

- [x] F1. **Plan Compliance Audit** — `deep`
  Read the plan end-to-end. For each "Must Have": verify implementation exists (read file, run command). For each "Must NOT Have": search codebase for forbidden patterns — reject with file:line if found. Check evidence files exist in .sisyphus/evidence/. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [x] F2. **Scope Fidelity Check** — `deep`
  For each task: read "What to do", read actual diff (git log/diff). Verify 1:1 — everything in spec was built (no missing), nothing beyond spec was built (no creep). Check "Must NOT do" compliance. Detect cross-task contamination: Task N touching Task M's files. Flag unaccounted changes.
  Output: `Tasks [N/N compliant] | Contamination [CLEAN/N issues] | Unaccounted [CLEAN/N files] | VERDICT`

---

## Commit Strategy

| After Task(s) | Message | Key Files | Verification |
|------------|---------|-------|--------------|
| 1 | `refactor(modules): extract darwin modules and create directory scaffold` | modules/darwin/*.nix | nix-instantiate --parse |
| 2, 3 | `refactor(home): move hyprland to desktop/ and flatten profiles into programs/` | home/desktop/hyprland/*, home/programs/base.nix, home/programs/development.nix | nix-instantiate --parse |
| 4 | `refactor(home): decompose gui.nix into pc.nix and hyprland desktop` | home/users/chase/pc.nix, home/desktop/hyprland/default.nix | nix-instantiate --parse |
| 5, 6 | `refactor(home): update macbook and macbook-vm imports for new paths` | home/users/chase/macbook.nix, home/users/chase/macbook-vm.nix | nix-instantiate --parse |
| 7 | `refactor(darwin): slim macbook host config to use darwin modules` | hosts/macbook/default.nix | nix-instantiate --parse |
| 8 | `refactor(home): remove old profiles directory and stale files` | home/profiles/ (deleted), home/programs/hyprland/ (deleted) | grep for stale refs |

---

## Success Criteria

### Final Directory Tree (After Restructure)
```
.nixconf/
├── flake.nix                          # UNCHANGED
├── flake.lock                         # UNCHANGED
├── AGENT.md                           # UNCHANGED
├── .github/workflows/build.yml        # UNCHANGED
├── hosts/
│   ├── pc/
│   │   ├── default.nix                # UNCHANGED
│   │   └── hardware-configuration.nix # UNCHANGED
│   ├── macbook/
│   │   └── default.nix                # SLIMMED (imports darwin modules)
│   └── macbook-vm/
│       ├── default.nix                # UNCHANGED
│       └── orbstack.nix               # UNCHANGED
├── modules/
│   ├── nixos/                         # ALL 10 FILES UNCHANGED
│   │   ├── 1password-cli.nix
│   │   ├── 1password.nix
│   │   ├── base.nix
│   │   ├── docker.nix
│   │   ├── files.nix
│   │   ├── gaming.nix
│   │   ├── greetd.nix
│   │   ├── ledger.nix
│   │   ├── nvidia.nix
│   │   └── pam-services.nix
│   └── darwin/                        # NEW
│       ├── base.nix                   # Extracted from macbook host
│       └── homebrew.nix               # Extracted from macbook host
└── home/
    ├── desktop/                       # NEW
    │   └── hyprland/                  # MOVED from programs/hyprland/
    │       ├── default.nix            # + kitty config added (from gui.nix)
    │       ├── flux.nix
    │       ├── keybindings.nix
    │       ├── launcher.nix
    │       ├── lock.nix
    │       ├── notifications.nix
    │       ├── screenshot.nix
    │       ├── screenshot.sh
    │       ├── theme.nix
    │       ├── wallpaper.jpg
    │       ├── wallpaper.nix
    │       └── windowrules.nix
    ├── programs/                       # FLATTENED (profiles/ merged in)
    │   ├── base.nix                   # MOVED from profiles/ (paths updated)
    │   ├── development.nix            # MOVED from profiles/ (paths updated)
    │   ├── aerospace.nix              # UNCHANGED
    │   ├── language-servers.nix       # UNCHANGED
    │   ├── main.zsh-theme             # UNCHANGED
    │   ├── opencode.nix               # UNCHANGED
    │   ├── solana.nix                 # UNCHANGED (intentionally orphaned)
    │   ├── zed.nix                    # UNCHANGED
    │   └── zsh.nix                    # UNCHANGED
    └── users/
        └── chase/
            ├── pc.nix                 # UPDATED (new imports + zed-editor package)
            ├── macbook.nix            # UPDATED (import paths only)
            ├── macbook-vm.nix         # UPDATED (import paths only)
            ├── aerospace.toml         # UNCHANGED
            ├── oh-my-opencode.jsonc   # UNCHANGED
            ├── opencode.json          # UNCHANGED
            ├── zed-keymap.json        # UNCHANGED
            └── zed-settings.json      # UNCHANGED
```

### Verification Commands
```bash
nix build .#nixosConfigurations.pc.config.system.build.toplevel --no-link --dry-run  # Expected: success
nix build .#darwinConfigurations.macbook.system --no-link --dry-run                   # Expected: success
nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-link --dry-run  # Expected: success
```

### Final Checklist
- [ ] All "Must Have" present
- [ ] All "Must NOT Have" absent
- [ ] All 3 machine configs evaluate successfully
- [ ] Zero stale import references
- [ ] `profiles/` directory removed
- [ ] `modules/darwin/` directory exists with 2 modules
- [ ] `home/desktop/hyprland/` exists with all 12 files
- [ ] `pkgs.zed-editor` in PC's home packages
- [ ] Kitty configured for both PC and macbook
