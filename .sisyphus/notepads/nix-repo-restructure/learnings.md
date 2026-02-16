# Learnings - NixOS Repo Restructure

## Conventions & Patterns
(Subagents append findings here)

## Task 1: Darwin Module Extraction (2026-02-16)

### Patterns Discovered
- Darwin modules mirror NixOS module structure (base.nix for core settings, specialized modules for specific concerns)
- `home-manager.backupFileExtension` is darwin-specific and belongs in darwin base module
- Homebrew configuration cleanly separates into its own module (GUI apps not available via Nix)

### Successful Approaches
- Created directory scaffold first (`modules/darwin/`, `home/desktop/`)
- Used `.gitkeep` to ensure git tracks empty `home/desktop/` directory before hyprland migration
- Validated Nix syntax with `nix-instantiate --parse` immediately after file creation
- Both modules parse successfully as valid Nix expressions

### Module Organization
- `modules/darwin/base.nix`: Core darwin settings (allowUnfree, systemPackages, zsh, home-manager backup)
- `modules/darwin/homebrew.nix`: macOS-specific GUI apps via Homebrew casks
- Mirrors existing `modules/nixos/base.nix` organizational pattern


## Task 7: Slim Macbook Host Config

**Date**: 2026-02-16

**What was done**:
- Slimmed `hosts/macbook/default.nix` from 64 lines to 33 lines
- Added imports for `modules/darwin/base.nix` and `modules/darwin/homebrew.nix`
- Removed inline config now in modules:
  - `nixpkgs.config.allowUnfree = true`
  - `environment.systemPackages` block
  - `programs.zsh.enable = true`
  - `home-manager.backupFileExtension`
  - Entire `homebrew = { ... }` block
- Preserved host-specific settings:
  - `determinateNix.customSettings.trusted-users`
  - `users.users.chase` block
  - `system.primaryUser`
  - `home-manager` block (without backupFileExtension)
  - `system.stateVersion`

**Pattern learned**:
- Host configs should only contain host-specific settings
- Common darwin settings belong in shared modules
- Import paths use relative paths from host directory: `../../modules/darwin/`
- When grep checks for removed config, import paths may match (e.g., "homebrew.nix" contains "homebrew")
- This is acceptable - the actual configuration block is what matters

**Verification**:
- All inline config successfully removed
- Imports present and correct
- Nix syntax validates successfully
- File reduced by ~48% (64 → 33 lines)


## Task 2: Move hyprland/ from programs/ to desktop/

### Execution Summary
- Used `git mv home/programs/hyprland home/desktop/hyprland` to preserve git history
- Removed `home/desktop/.gitkeep` after move (no longer needed)
- All 12 files moved successfully with 100% similarity (R100 status)

### Key Learnings
1. **Git mv preserves history**: Using `git mv` instead of `mv` ensures git tracks the move as a rename with 100% similarity
2. **Relative imports survive moves**: All internal imports within hyprland/ use `./` relative paths, so they remain valid after directory relocation
3. **Nix parse validation**: `nix-instantiate --parse` confirms syntax integrity after file operations
4. **Gitkeep cleanup**: After moving content into a directory, remove `.gitkeep` files as they're no longer needed

### Files Moved (12 total)
- default.nix (entry point with imports)
- flux.nix, keybindings.nix, launcher.nix, lock.nix
- notifications.nix, screenshot.nix, screenshot.sh
- theme.nix, wallpaper.jpg, wallpaper.nix, windowrules.nix

### Verification Results
- ✅ All 12 files present in `home/desktop/hyprland/`
- ✅ `default.nix` parses successfully
- ✅ Git shows R100 (100% similarity) for all files
- ✅ Zero content modifications during move

### Pattern Confirmed
- Desktop environment modules belong in `home/desktop/` not `home/programs/`
- This aligns with the architectural decision from Task 1

## Task 3: Move base.nix and development.nix to programs/

**Date**: 2026-02-16

**What worked**:
- Used `git mv` to preserve file history when moving files
- Updated import paths from `../programs/X.nix` to `./X.nix` after moving files into programs/ directory
- Validated Nix syntax immediately after path updates using `nix-instantiate --parse`
- Verified no stale paths remained using `grep -c '../programs/'` (expected 0 matches)

**Key patterns**:
- When moving files between directories, import paths must be updated to reflect new relative locations
- Files moving FROM `home/profiles/` INTO `home/programs/` change sibling references from `../programs/` to `./`
- Always validate Nix syntax after structural changes to catch path errors early

**Import path transformation logic**:
- Old location: `home/profiles/base.nix` importing `home/programs/opencode.nix` → path: `../programs/opencode.nix`
- New location: `home/programs/base.nix` importing `home/programs/opencode.nix` → path: `./opencode.nix`
- Same directory imports use `./` prefix

**Verification approach**:
1. Move files with `git mv` (preserves history)
2. Update import paths in moved files
3. Grep for stale paths (should return 0 matches)
4. Validate Nix syntax with `nix-instantiate --parse`
5. Save evidence files documenting all checks

**Files affected**:
- `home/programs/base.nix` - Updated 2 import paths
- `home/programs/development.nix` - Updated 1 import path


## Task 5: macbook.nix Import Updates (2026-02-16)

### What Changed
- Updated `home/users/chase/macbook.nix` imports from `../../profiles/` to `../../programs/`
- Changed: base.nix and development.nix paths
- Unchanged: zed.nix and aerospace.nix (already under programs/)

### Key Learnings
1. **macOS-specific config preservation**: macbook.nix has intentional differences from PC config:
   - `package = pkgs.emptyDirectory` hack for kitty (line 38)
   - macOS-specific kitty settings (background_opacity, macos_quit_when_last_window_closed)
   - Must verify these remain untouched during refactors

2. **Import path updates**: Simple string replacement in imports block
   - Only changed first 2 imports (profiles → programs)
   - Last 2 imports already correct (programs/)

3. **Verification pattern**: 
   - `grep 'profiles/'` → 0 matches (no stale paths)
   - `grep 'programs/X'` → 1 match per import (all correct)
   - `nix-instantiate --parse` → valid syntax

### Evidence Files
- `.sisyphus/evidence/task-5-macbook-imports.txt` - Import path verification
- `.sisyphus/evidence/task-5-macbook-kitty-preserved.txt` - macOS config preservation

### Success Metrics
- ✅ All 4 imports point to programs/
- ✅ No stale profiles/ paths
- ✅ Valid Nix syntax
- ✅ macOS-specific kitty config preserved

## Task 6: Update macbook-vm.nix imports (2026-02-16)

**What worked:**
- Simple path substitution: `../../profiles/` → `../../programs/`
- Both imports updated cleanly (base.nix, development.nix)
- nix-instantiate validation confirms syntax correctness

**Pattern observed:**
- User config files follow same import pattern as darwin.nix
- Comment "# Shared profiles" remains accurate (programs are profiles)
- VM-specific config inherits all dev tools from development.nix

**Verification approach:**
- grep for stale paths (profiles/) → 0 matches
- grep for new paths (programs/base.nix, programs/development.nix) → 1 match each
- nix-instantiate --parse validates syntax

**Result:** macbook-vm.nix now imports from programs/ directory. Ready for grouped commit with Task 5.

## Task 4: Decompose gui.nix and Update pc.nix (Completed)

### What Was Done
- **gui.nix decomposition**: Redistributed 3 responsibilities from gui.nix to appropriate locations:
  1. `programs/zed.nix` import → added directly to pc.nix imports
  2. `pkgs.zed-editor` package → added to pc.nix home.packages
  3. `programs.kitty` config → moved to hyprland/default.nix (PC's desktop environment)

### Files Modified
- `home/users/chase/pc.nix`:
  - Changed imports from `../../profiles/` to `../../programs/` for base.nix and development.nix
  - Added `../../programs/zed.nix` import
  - Changed `../../programs/hyprland` to `../../desktop/hyprland`
  - Added `pkgs.zed-editor` to home.packages list
- `home/desktop/hyprland/default.nix`:
  - Added complete kitty configuration block with exact settings from gui.nix
  - Placed after existing programs/services config

### Key Patterns
- **Desktop-specific config goes in desktop modules**: Kitty terminal config belongs in hyprland desktop, not in user profile
- **Program imports go directly to user configs**: zed.nix import moved from gui.nix to pc.nix directly
- **Package lists stay in user configs**: zed-editor package added to pc.nix home.packages
- **Exact reproduction required**: Kitty config copied verbatim (enable, shellIntegration, extraConfig with window_margin_width and font_size)

### Verification Success
- All stale paths removed (no profiles/, no programs/hyprland, no gui.nix)
- All new paths present (programs/base.nix, programs/development.nix, programs/zed.nix, desktop/hyprland)
- zed-editor in home.packages
- Kitty config complete in hyprland/default.nix
- Both files parse successfully with nix-instantiate

### Evidence Files
- `.sisyphus/evidence/task-4-pc-imports.txt` - pc.nix import verification
- `.sisyphus/evidence/task-4-kitty-in-hyprland.txt` - kitty config verification

## Task 8: Delete old directories and stale files

### Cleanup Execution
- **Deleted files**: `home/profiles/gui.nix` (only remaining file in profiles/)
- **Deleted directories**: `home/profiles/` (automatically removed when empty)
- **Already removed**: `home/programs/hyprland/` (removed in previous task)
- **Preserved**: `home/programs/solana.nix` (intentionally kept)

### Git Operations
- Used `git rm` for tracked file removal to preserve history
- Directory automatically removed when last file deleted
- Previous tasks had already removed `base.nix`, `development.nix`, and `hyprland/`

### Verification Results
- ✅ All old directories successfully removed
- ✅ Expected files preserved (solana.nix, all programs/)
- ✅ New locations verified (home/desktop/hyprland/)
- ✅ Zero stale references found in codebase

### Stale Reference Checks
- Searched for `profiles/` in home/, hosts/, modules/ → 0 matches
- Searched for `programs/hyprland` in home/users/ → 0 matches
- Searched for `gui\.nix` in home/ → 0 matches
- All previous tasks successfully updated references

### Evidence Files
- `.sisyphus/evidence/task-8-cleanup.txt` - Deletion verification
- `.sisyphus/evidence/task-8-no-stale-refs.txt` - Stale reference checks


## Task 9: Full verification of all machine configs (2026-02-16)

### Verification outcomes
- All 3 flake outputs evaluated successfully via  (pc, macbook, macbook-vm), each with 
- Package preservation confirmed:  is  for both pc and macbook
- PC package presence confirmed:  still present in  (evaluates )
- Structural checks passed:  absent,  present with  and ,  present with 12 items,  absent
- No stale  references found across , , and 

### Verification pattern reinforced
- Final restructure QA should include both eval-level checks (, ) and filesystem-level structural checks
- Capturing command output plus explicit  values in evidence files makes review deterministic

## Task 9: Full verification of all machine configs (2026-02-16) - corrected entry

### Verification outcomes
- All 3 flake outputs evaluated successfully via `nix build --dry-run` (pc, macbook, macbook-vm), each with `EXIT_CODE:0`
- Package preservation confirmed: `programs.kitty.enable` is `true` for both pc and macbook
- PC package presence confirmed: `pkgs.zed-editor` still present in `home-manager.users.chase.home.packages` (evaluates `true`)
- Structural checks passed: `home/profiles/` absent, `modules/darwin/` present with `base.nix` and `homebrew.nix`, `home/desktop/hyprland/` present with 12 items, `home/programs/hyprland/` absent
- No stale `profiles/` references found across `home/`, `hosts/`, and `modules/`

### Verification pattern reinforced
- Final restructure QA should include both eval-level checks (`nix build --dry-run`, `nix eval`) and filesystem-level structural checks
- Capturing command output plus explicit `EXIT_CODE` values in evidence files makes review deterministic
- 2026-02-16 F1 audit: validated all 6 Must Have and 13 Must NOT Have checks via file reads, grep scans, git-path guardrail checks, nix dry-run builds (pc/macbook/macbook-vm exit 0), and evidence coverage for tasks 1-9.

## F2: Scope fidelity check (2026-02-16)

- Scope-fidelity must be validated per task boundary, not only final repository state.
- Cross-task contamination occurred in `b34481d` (Task 2, Task 3, and Task 7 file changes in one commit), so those tasks are not 1:1 scoped.
- Task 8 cleanup actions were partially pre-consumed by earlier task execution order (old paths removed before dedicated cleanup step), breaking strict task isolation.
- Unaccounted branch changes exist outside this plan scope (`flake.nix`, `flake.lock`, `home/programs/opencode.nix`, `home/programs/language-servers.nix`, `hosts/macbook-vm/default.nix`, and multiple `.sisyphus/opencode-serve/*` artifacts).
- Task 4 has minor scope creep in `home/users/chase/pc.nix` (comment changed from "Shared profiles" to "Shared programs" beyond required import/package edits).
