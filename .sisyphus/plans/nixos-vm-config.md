# NixOS OrbStack VM Configuration

## TL;DR

> **Quick Summary**: Add a headless NixOS development environment to the flake for an OrbStack VM on macOS. Refactor shared profiles to cleanly separate GUI from CLI-only packages, then create the new VM host config based on the PC config minus all desktop/hardware-specific modules.
> 
> **Deliverables**:
> - Refactored `base.nix` with GUI packages extracted to `gui.nix`
> - New `zed-lsp.nix` module for language servers without the editor
> - New `hosts/macbook-vm/` host configuration (headless NixOS for OrbStack)
> - New `home/users/chase/macbook-vm.nix` home-manager config
> - New `modules/nixos/1password-cli.nix` (CLI-only variant)
> - Updated `flake.nix` with `nixosConfigurations.macbook-vm`
> - Existing PC and macbook configs verified to still build
> 
> **Estimated Effort**: Medium
> **Parallel Execution**: YES - 2 waves
> **Critical Path**: Task 0 (get orbstack.nix) → Task 1 (refactor base.nix) → Task 3 (VM host config) → Task 5 (flake.nix) → Task 6 (verify all)

---

## Context

### Original Request
User wants to add a 3rd environment to their Nix flake: a NixOS VM running via OrbStack on macOS. This VM serves as a headless development box — all GUI apps run natively on macOS, Zed editor connects to the VM via SSH remote development. The VM config should be based on the PC config but stripped of all GUI/desktop/hardware-specific modules.

### Interview Summary
**Key Discussions**:
- VM is headless — no Hyprland, greetd, NVIDIA, gaming, audio, ledger, thunar
- 1Password CLI: YES, include on VM (no GUI)
- Refactor `base.nix`: split GUI packages (kitty, zed-editor) into separate `gui.nix` profile
- Zed LSP servers (nil, nixd, rust-analyzer, etc.) needed on VM for remote dev, but not zed-editor itself
- OrbStack VM already exists, `orb` CLI installed on macOS
- Docker: keep in VM (user confirmed by not excluding it)

**Research Findings**:
- OrbStack = Apple Virtualization.framework, native aarch64-linux, no emulation
- SSH built-in via `ssh orb` — no sshd needed in VM config
- VirtioFS file sharing — macOS dirs auto-mounted at `/mnt/mac/...`
- Must import OrbStack-generated `orbstack.nix` + potentially `lxc-container.nix`
- Networking: systemd-networkd (OrbStack handles it via orbstack.nix)
- UID should be 501 to match macOS for VirtioFS file permissions
- Rosetta x86 emulation available via `nix.settings.extra-platforms`
- Reference config: github.com/PoisonPhang/orbstack-nixos-config

### Metis Review
**Identified Gaps (addressed)**:
- Zed module split is more nuanced: LSP servers must stay accessible to VM, editor must not. Created `zed-lsp.nix` approach.
- `docker.nix` iptables rules may conflict with OrbStack networking. VM variant should omit firewall rules.
- `extensions.zed` option must NOT be referenced in VM config (would error since zed.nix not imported).
- `rust-overlay` and `foundry` overlays must be included in VM flake entry (development.nix depends on them).
- `boot.loader.*` and `networking.networkmanager.*` must NOT be set in VM (orbstack.nix owns these).
- Existing configs must be regression-tested after refactor, not just at the end.

---

## Work Objectives

### Core Objective
Add `nixosConfigurations.macbook-vm` to the flake — a headless NixOS development environment for OrbStack that shares dev tooling with the PC config but excludes all GUI/desktop/hardware concerns.

### Concrete Deliverables
- `hosts/macbook-vm/default.nix` — VM system configuration
- `hosts/macbook-vm/orbstack.nix` — copied from OrbStack VM
- `home/users/chase/macbook-vm.nix` — VM home-manager configuration
- `home/profiles/gui.nix` — extracted GUI packages (kitty, zed-editor)
- `home/programs/zed-lsp.nix` — LSP servers only (no editor)
- `modules/nixos/1password-cli.nix` — CLI-only 1Password
- Modified `home/profiles/base.nix` — GUI packages removed
- Modified `home/programs/zed.nix` — imports zed-lsp.nix, keeps editor + activation
- Modified `home/users/chase/pc.nix` — imports gui.nix
- Modified `home/users/chase/macbook.nix` — imports gui.nix
- Modified `flake.nix` — new nixosConfigurations entry

### Definition of Done
- [x] `nix flake check` passes
- [x] `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run` succeeds
- [x] `nix build .#darwinConfigurations.macbook.system --dry-run` succeeds
- [x] `nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run` succeeds
- [x] VM config contains LSP servers but NOT zed-editor or kitty
- [x] PC config still contains kitty, zed-editor, and all GUI packages

### Must Have
- LSP servers (nil, nixd, rust-analyzer, markdown-oxide, package-version-server) available in VM
- Docker available in VM
- 1Password CLI available in VM
- All dev tools (node, bun, rust, go, pnpm) available in VM
- zsh with same config as PC
- UID 501 for macOS file permission alignment
- Rosetta x86 support enabled

### Must NOT Have (Guardrails)
- `zed-editor` package in VM
- `kitty` terminal in VM
- Hyprland, greetd, or any display/window manager
- NVIDIA drivers, CUDA
- Steam/gaming
- Pipewire/audio
- Printing, udisks2, upower
- Gnome keyring, hyprlock PAM
- Thunar file manager
- Ledger USB rules
- xremap/uinput
- Wayland environment variables (`NIXOS_OZONE_WL`, `ELECTRON_OZONE_PLATFORM_HINT`)
- `boot.loader.*` settings (orbstack.nix handles boot)
- `networking.networkmanager` (OrbStack uses systemd-networkd)
- `sshd` (OrbStack provides SSH access natively)
- Fabricated `orbstack.nix` content — must be copied from real VM

---

## Verification Strategy

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.

### Test Decision
- **Infrastructure exists**: NO (this is Nix config, not application code)
- **Automated tests**: NO — verification is via `nix build --dry-run` and `nix flake check`
- **Framework**: N/A

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

Verification is done via `nix` CLI commands that evaluate the flake without needing a running VM.

**Verification Tool by Deliverable Type:**

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| Nix config correctness | Bash (`nix flake check`) | Evaluates all outputs, catches syntax/type errors |
| Build success | Bash (`nix build --dry-run`) | Verifies derivation resolves without actually building |
| Package presence/absence | Bash (`nix eval`) | Evaluates package lists in config |
| Regression (existing configs) | Bash (`nix build --dry-run`) | Existing configs still resolve |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 0 (Prerequisite — user action):
└── Task 0: Copy orbstack.nix from VM into repo

Wave 1 (Refactor — must be sequential within wave):
├── Task 1: Refactor base.nix → base.nix + gui.nix + zed-lsp.nix (+ update zed.nix)
└── Task 2: Update pc.nix and macbook.nix to import gui.nix + verify regression

Wave 2 (New config — after Wave 1 verified):
├── Task 3: Create hosts/macbook-vm/default.nix
├── Task 4: Create home/users/chase/macbook-vm.nix + modules/nixos/1password-cli.nix
└── Task 5: Update flake.nix with macbook-vm entry

Wave 3 (Verify all):
└── Task 6: Full verification — flake check + dry-build all 3 configs + package assertions
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 0 | None (user) | 3 | 1, 2 |
| 1 | None | 2, 4 | 0 |
| 2 | 1 | 3, 4, 5 | — |
| 3 | 0, 2 | 5, 6 | 4 |
| 4 | 2 | 5, 6 | 3 |
| 5 | 3, 4 | 6 | — |
| 6 | 5 | None | — |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 0 | 0 | User action (orb CLI) |
| 1 | 1, 2 | task(category="quick", load_skills=[], ...) — sequential |
| 2 | 3, 4 | task(category="quick", load_skills=[], ...) — can parallel |
| 2 | 5 | task(category="quick", load_skills=[], ...) — after 3+4 |
| 3 | 6 | task(category="quick", load_skills=[], ...) |

---

## TODOs

- [x] 0. Copy `orbstack.nix` from OrbStack VM into repo

  **What to do**:
  - Run: `orb run nixos cat /etc/nixos/orbstack.nix > hosts/macbook-vm/orbstack.nix`
    - If the machine name is not `nixos`, check with `orb list` first and use the correct name
  - Verify the file was copied and is non-empty
  - Do NOT modify this file — it's OrbStack-generated and should be treated as read-only
  - Also check if it imports `lxc-container.nix` internally (if so, Task 3 should NOT also import it)

  **Must NOT do**:
  - Fabricate or generate this file from scratch
  - Modify the contents of the file

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
    - No special skills needed, just shell commands
  - **Skills Evaluated but Omitted**:
    - None relevant

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 1)
  - **Parallel Group**: Wave 0/1
  - **Blocks**: Task 3 (needs orbstack.nix to exist)
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `hosts/pc/hardware-configuration.nix` — similar role: hardware/platform-specific config that's generated, not hand-written

  **External References**:
  - OrbStack NixOS VM config: https://github.com/PoisonPhang/orbstack-nixos-config/blob/1f19e2f/orb/orbstack.nix — reference for what orbstack.nix typically contains (systemd watchdog workarounds, DNS resolver, shell init scripts, SSH config, resolved settings)

  **WHY Each Reference Matters**:
  - The PoisonPhang reference shows what to expect in orbstack.nix (networking, DNS, boot, systemd workarounds). If the user's generated file looks wildly different, something may be wrong.

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: orbstack.nix exists and is non-empty
    Tool: Bash
    Preconditions: OrbStack VM running, orb CLI available
    Steps:
      1. mkdir -p hosts/macbook-vm
      2. orb list (verify NixOS machine name)
      3. orb run <machine-name> cat /etc/nixos/orbstack.nix > hosts/macbook-vm/orbstack.nix
      4. wc -l hosts/macbook-vm/orbstack.nix
      5. Assert: file has > 10 lines
      6. grep -q "orbstack" hosts/macbook-vm/orbstack.nix
      7. Assert: grep finds matches (confirms it's OrbStack-generated)
    Expected Result: orbstack.nix copied into repo with OrbStack-specific configuration
    Failure Indicators: Empty file, file not created, orb command fails
    Evidence: File contents shown via head -50
  ```

  **Commit**: NO (groups with Task 3)

---

- [x] 1. Refactor `base.nix`: extract GUI packages to `gui.nix` and create `zed-lsp.nix`

  **What to do**:

  **Step 1 — Create `home/programs/zed-lsp.nix`:**
  - New file containing only the LSP server packages from `home/programs/zed.nix`:
    - `pkgs.nil`
    - `pkgs.nixd`
    - `pkgs.package-version-server`
    - `pkgs.rust-analyzer`
    - `pkgs.markdown-oxide`
  - Simple structure: `{ pkgs, ... }: { home.packages = [ ... ]; }`
  - No options, no activation script, no zed-editor

  **Step 2 — Modify `home/programs/zed.nix`:**
  - Add `imports = [ ./zed-lsp.nix ];` at the top of the config block
  - Remove the LSP packages from `home.packages` (they now come from zed-lsp.nix)
  - Keep: `zed-editor` package, `extensions.zed` options, activation script — all unchanged
  - Net behavior for existing configs: identical (zed.nix imports zed-lsp.nix, so all packages still present)

  **Step 3 — Create `home/profiles/gui.nix`:**
  - New file that imports `../programs/zed.nix` and contains the `programs.kitty` block
  - Structure:
    ```nix
    { pkgs, ... }:
    {
      imports = [
        ../programs/zed.nix
      ];

      programs.kitty = {
        enable = true;
        shellIntegration.enableZshIntegration = true;
        extraConfig = ''
          window_margin_width 10
          font_size 18.0
        '';
      };
    }
    ```

  **Step 4 — Modify `home/profiles/base.nix`:**
  - Remove `../programs/zed.nix` from imports (moved to gui.nix)
  - Remove entire `programs.kitty` block (lines 34-41, moved to gui.nix)
  - Keep everything else: zsh.nix import, packages, git, htop, home-manager, sessionVariables

  **Must NOT do**:
  - Change any package versions or settings
  - Modify zsh.nix, development.nix, or any other existing profile
  - Add new packages not already present
  - Remove packages from the overall set (just relocate them)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: No UI work involved

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 0)
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 2 (must verify imports work before updating user configs)
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `home/profiles/base.nix:1-47` — The file being refactored. Lines 4-7 are imports (remove zed.nix), lines 34-41 are kitty config (move to gui.nix), everything else stays.
  - `home/programs/zed.nix:1-51` — The Zed module. Lines 28-35 are packages to extract to zed-lsp.nix. Lines 11-25 are options and lines 37-48 are activation — these stay in zed.nix.
  - `home/profiles/development.nix:1-20` — Example of a clean profile structure to follow for gui.nix

  **WHY Each Reference Matters**:
  - `base.nix` is the exact file being modified — executor needs to see current state to make precise edits
  - `zed.nix` packages at lines 28-35 must be split precisely — missing a package breaks Zed remote dev
  - `development.nix` shows the pattern: `{ pkgs, ... }: { ... }` — gui.nix should follow same structure

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: New files created with correct content
    Tool: Bash
    Preconditions: Repo at current state
    Steps:
      1. Verify home/programs/zed-lsp.nix exists
      2. grep -q "nil" home/programs/zed-lsp.nix && grep -q "nixd" home/programs/zed-lsp.nix && grep -q "rust-analyzer" home/programs/zed-lsp.nix
      3. Assert: all LSP packages present in zed-lsp.nix
      4. Verify home/profiles/gui.nix exists
      5. grep -q "kitty" home/profiles/gui.nix && grep -q "zed.nix" home/profiles/gui.nix
      6. Assert: gui.nix has kitty and imports zed.nix
    Expected Result: Both new files exist with correct content
    Evidence: cat output of both files

  Scenario: base.nix no longer contains GUI packages
    Tool: Bash
    Preconditions: Task 1 edits applied
    Steps:
      1. grep "kitty" home/profiles/base.nix
      2. Assert: no matches (kitty removed)
      3. grep "zed.nix" home/profiles/base.nix
      4. Assert: no matches (zed import removed)
      5. grep "zsh.nix" home/profiles/base.nix
      6. Assert: match found (zsh still imported)
      7. grep "fzf" home/profiles/base.nix
      8. Assert: match found (CLI packages still present)
    Expected Result: base.nix is CLI-only, no GUI references remain
    Evidence: Full file contents shown

  Scenario: zed.nix imports zed-lsp.nix and keeps editor
    Tool: Bash
    Preconditions: Task 1 edits applied
    Steps:
      1. grep "zed-lsp.nix" home/programs/zed.nix
      2. Assert: match found (imports zed-lsp)
      3. grep "zed-editor" home/programs/zed.nix
      4. Assert: match found (editor still present)
      5. grep -c "nil\|nixd\|rust-analyzer\|markdown-oxide\|package-version-server" home/programs/zed.nix
      6. Assert: count is 0 or only in import (LSP packages moved to zed-lsp.nix)
    Expected Result: zed.nix delegates LSP to zed-lsp.nix, keeps editor + options + activation
    Evidence: Full file contents shown
  ```

  **Commit**: YES
  - Message: `refactor(home): extract GUI packages from base.nix into gui.nix and zed-lsp.nix`
  - Files: `home/profiles/base.nix`, `home/profiles/gui.nix`, `home/programs/zed.nix`, `home/programs/zed-lsp.nix`
  - Pre-commit: files parse correctly (no syntax errors)

---

- [x] 2. Update `pc.nix` and `macbook.nix` to import `gui.nix` + verify regression

  **What to do**:

  **Step 1 — Modify `home/users/chase/pc.nix`:**
  - Add `../../profiles/gui.nix` to the imports list (after `../../profiles/development.nix`)
  - No other changes — behavior must be identical to before

  **Step 2 — Modify `home/users/chase/macbook.nix`:**
  - Add `../../profiles/gui.nix` to the imports list (after `../../profiles/development.nix`)
  - No other changes

  **Step 3 — Verify regression:**
  - Run: `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run`
  - Run: `nix build .#darwinConfigurations.macbook.system --dry-run`
  - Both must succeed with exit code 0
  - This confirms the refactor didn't break anything

  **Must NOT do**:
  - Change any other imports or settings in these files
  - Modify packages, aliases, or session variables
  - Skip the regression verification

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Skills Evaluated but Omitted**: None relevant

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential (after Task 1)
  - **Blocks**: Tasks 3, 4, 5 (must confirm refactor is clean before building on it)
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `home/users/chase/pc.nix:4-14` — Current imports list. Add `../../profiles/gui.nix` after line with `../../profiles/development.nix`
  - `home/users/chase/macbook.nix:4-8` — Current imports list. Add `../../profiles/gui.nix` after `../../profiles/development.nix`

  **WHY Each Reference Matters**:
  - Exact line numbers where the import needs to be added — executor must not add it in wrong place
  - The import order matters for Nix module merging (gui after development is correct)

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: PC config builds successfully after refactor
    Tool: Bash
    Preconditions: Task 1 complete, pc.nix updated
    Steps:
      1. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1
      2. Assert: exit code 0
      3. Assert: no "error:" in output
    Expected Result: PC config resolves identically to before refactor
    Evidence: Command output captured

  Scenario: macbook config builds successfully after refactor
    Tool: Bash
    Preconditions: Task 1 complete, macbook.nix updated
    Steps:
      1. nix build .#darwinConfigurations.macbook.system --dry-run 2>&1
      2. Assert: exit code 0
      3. Assert: no "error:" in output
    Expected Result: macbook config resolves identically to before refactor
    Evidence: Command output captured
  ```

  **Commit**: YES
  - Message: `refactor(home): add gui.nix import to pc and macbook user configs`
  - Files: `home/users/chase/pc.nix`, `home/users/chase/macbook.nix`
  - Pre-commit: `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run && nix build .#darwinConfigurations.macbook.system --dry-run`

---

- [x] 3. Create `hosts/macbook-vm/default.nix` — VM system configuration

  **What to do**:
  - Create `hosts/macbook-vm/default.nix` based on `hosts/pc/default.nix` structure but headless
  - First: read `hosts/macbook-vm/orbstack.nix` (from Task 0) to check what it already handles (boot, networking, DNS, etc.). Do NOT duplicate anything orbstack.nix already configures.
  - If orbstack.nix already imports `lxc-container.nix`, do NOT import it again. If it doesn't, add the import.

  **Configuration contents:**
  ```nix
  { pkgs, inputs, modulesPath, ... }:
  {
    imports = [
      ./orbstack.nix
      ../../modules/nixos/docker.nix  # NOTE: see below about iptables
      ../../modules/nixos/1password-cli.nix
      # Add lxc-container.nix ONLY if orbstack.nix doesn't already import it:
      # "${modulesPath}/virtualisation/lxc-container.nix"
    ];

    # Hostname
    networking.hostName = "macbook-vm";

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.trusted-users = [ "root" "@wheel" "chase" ];

    # Rosetta x86 emulation
    nix.settings.extra-platforms = [ "x86_64-linux" "i686-linux" ];

    # Locale (same as PC)
    time.timeZone = "America/Boise";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Shell
    programs.zsh.enable = true;

    # User — UID 501 to match macOS for VirtioFS file permissions
    users.users.chase = {
      uid = 501;
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "Chase";
      extraGroups = [ "wheel" "docker" ];
    };

    # System packages
    environment.systemPackages = with pkgs; [ git wget ];

    # Home Manager
    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      useGlobalPkgs = true;
      users."chase" = import ../../home/users/chase/macbook-vm.nix;
    };

    # Dynamic binaries
    programs.nix-ld.enable = true;

    system.stateVersion = "24.05";
  }
  ```

  **Docker iptables consideration**: The `docker.nix` module has `networking.firewall.extraCommands` with iptables rules. These may conflict with OrbStack's networking. If the dry-build or runtime fails, create a `modules/nixos/docker-vm.nix` variant without the iptables rules. Try with the existing module first.

  **Must NOT do**:
  - Set `boot.loader.*` (orbstack.nix handles boot)
  - Set `networking.networkmanager.enable` (OrbStack uses systemd-networkd)
  - Enable pipewire, printing, udisks2, upower, gnome-keyring
  - Import hyprland, nvidia, greetd, gaming, ledger, files, pam-services modules
  - Set Wayland environment variables
  - Enable xremap/uinput
  - Set `nixpkgs.hostPlatform` here (orbstack.nix likely sets it; if not, add `lib.mkDefault "aarch64-linux"`)
  - Modify orbstack.nix

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Skills Evaluated but Omitted**: None relevant

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 4)
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 5 (flake.nix needs this to exist)
  - **Blocked By**: Task 0 (orbstack.nix), Task 2 (refactor verified)

  **References**:

  **Pattern References**:
  - `hosts/pc/default.nix:1-117` — The PC system config. Follow this structure but selectively include only headless-compatible settings. Lines 22-23 (boot.loader) SKIP. Lines 37-38 (networkmanager) SKIP. Lines 67-73 (pipewire) SKIP. Lines 79-80 (gnome-keyring) SKIP. Lines 92-94 (xremap/uinput) SKIP. Lines 109-113 (wayland vars) SKIP. Lines 27-29 (hostname, unfree) KEEP. Lines 33-34 (flakes, trusted-users) KEEP. Lines 41-53 (locale) KEEP. Lines 83-89 (user) ADAPT (uid=501). Lines 99-104 (home-manager) ADAPT (macbook-vm.nix).
  - `modules/nixos/docker.nix:1-18` — Docker module. Import as-is, but be aware lines 13-16 have iptables rules that may need removal for OrbStack.
  - `hosts/macbook-vm/orbstack.nix` — (from Task 0) Read this first to understand what it already configures. Do NOT duplicate boot, networking, or DNS settings it handles.

  **External References**:
  - OrbStack NixOS config reference: https://github.com/PoisonPhang/orbstack-nixos-config/blob/1f19e2f/orb/configuration.nix — real-world example of a minimal OrbStack NixOS system config

  **WHY Each Reference Matters**:
  - `hosts/pc/default.nix` is the template — executor needs to understand every line to decide include/exclude
  - `docker.nix` iptables lines may cause issues — executor should be ready to create a docker-vm variant
  - `orbstack.nix` must be read first — it may already set networking, boot, platform, which would conflict if duplicated

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: VM system config is valid Nix
    Tool: Bash
    Preconditions: orbstack.nix exists from Task 0
    Steps:
      1. cat hosts/macbook-vm/default.nix
      2. Verify file exists and has expected structure
      3. grep -q "macbook-vm" hosts/macbook-vm/default.nix
      4. Assert: hostname is set
      5. grep -q "uid = 501" hosts/macbook-vm/default.nix
      6. Assert: correct UID
      7. grep "hyprland\|nvidia\|greetd\|gaming\|pipewire\|ledger" hosts/macbook-vm/default.nix
      8. Assert: no matches (no GUI/hardware modules)
    Expected Result: Clean headless system config
    Evidence: File contents captured

  Scenario: VM config does not duplicate orbstack.nix concerns
    Tool: Bash
    Preconditions: orbstack.nix and default.nix both exist
    Steps:
      1. grep "boot.loader" hosts/macbook-vm/default.nix
      2. Assert: no matches
      3. grep "networkmanager" hosts/macbook-vm/default.nix
      4. Assert: no matches
    Expected Result: No conflicts with orbstack.nix
    Evidence: grep output
  ```

  **Commit**: NO (groups with Task 5)

---

- [x] 4. Create `home/users/chase/macbook-vm.nix` and `modules/nixos/1password-cli.nix`

  **What to do**:

  **Step 1 — Create `modules/nixos/1password-cli.nix`:**
  ```nix
  # 1Password CLI only (no GUI, no polkit)
  { ... }:
  {
    programs._1password.enable = true;
  }
  ```

  **Step 2 — Create `home/users/chase/macbook-vm.nix`:**
  ```nix
  # OrbStack VM (NixOS) home configuration for chase
  { pkgs, inputs, ... }:
  {
    imports = [
      # Shared profiles
      ../../profiles/base.nix
      ../../profiles/development.nix

      # LSP servers for Zed remote development
      ../../programs/zed-lsp.nix

      # Additional programs
      ../../programs/solana.nix
    ];

    home.username = "chase";
    home.homeDirectory = "/home/chase";
    home.stateVersion = "24.05";

    # VM-specific packages
    home.packages = [
      pkgs.gcc
      pkgs.mold
      pkgs.openssl
      pkgs.pkg-config
      pkgs.solc
      inputs.codex-cli-nix.packages.${pkgs.system}.default
    ];

    # VM-specific shell config
    home.shellAliases = {
      nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm";
      nixconf-update = "nix flake update --flake ~/.nixconf";
    };

    home.sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    };

    # VM-specific programs
    programs.pyenv.enable = true;
  }
  ```

  **Note**: This mirrors pc.nix's dev packages (gcc, mold, openssl, pkg-config, solc, codex-cli, pyenv) but excludes all GUI apps (pavucontrol, vesktop, slack, spotify, JetBrains, prismlauncher, obsidian, etc.) and does NOT set `extensions.zed` (that option isn't available since gui.nix/zed.nix aren't imported). Does NOT import Hyprland.

  **Must NOT do**:
  - Set `extensions.zed` (module not imported, would error)
  - Import `../../profiles/gui.nix` or `../../programs/hyprland`
  - Install GUI applications (vesktop, slack, spotify, obsidian, etc.)
  - Install `anki-bin`, `audacity`, `telegram-desktop`, `signal-desktop` (GUI apps from PC)
  - Install `openjdk25`, `glfw`, `prismlauncher` (gaming-related from PC)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Skills Evaluated but Omitted**: None relevant

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 3)
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 5 (flake.nix references these)
  - **Blocked By**: Task 2 (refactor must be verified first)

  **References**:

  **Pattern References**:
  - `home/users/chase/pc.nix:1-63` — Template for macbook-vm.nix. Lines 4-14 (imports): use base + development + zed-lsp + solana, skip gui + hyprland. Lines 27-48 (packages): carry over dev tools (gcc, mold, openssl, pkg-config, solc, codex-cli), skip ALL GUI apps. Lines 51-54 (aliases): adapt for VM. Lines 56-58 (sessionVariables): carry over PKG_CONFIG_PATH. Line 62 (pyenv): carry over.
  - `home/users/chase/macbook.nix:1-31` — Alternative template showing minimal home config pattern (simpler than PC)
  - `modules/nixos/1password.nix:1-10` — The GUI version. CLI-only variant removes lines 5-8 (the _1password-gui block)

  **WHY Each Reference Matters**:
  - `pc.nix` is the source of truth for which dev packages to include — must be compared line-by-line
  - `macbook.nix` shows the minimal pattern without GUI extras
  - `1password.nix` shows what to strip for CLI-only variant

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: 1password-cli.nix is CLI-only
    Tool: Bash
    Preconditions: File created
    Steps:
      1. cat modules/nixos/1password-cli.nix
      2. grep "_1password.enable" modules/nixos/1password-cli.nix
      3. Assert: match found
      4. grep "_1password-gui" modules/nixos/1password-cli.nix
      5. Assert: no match (no GUI)
      6. grep "polkit" modules/nixos/1password-cli.nix
      7. Assert: no match (no polkit)
    Expected Result: CLI-only 1Password module
    Evidence: File contents

  Scenario: macbook-vm.nix has correct imports and no GUI
    Tool: Bash
    Preconditions: File created
    Steps:
      1. cat home/users/chase/macbook-vm.nix
      2. grep "base.nix" home/users/chase/macbook-vm.nix
      3. Assert: match (imports base)
      4. grep "development.nix" home/users/chase/macbook-vm.nix
      5. Assert: match (imports dev profile)
      6. grep "zed-lsp.nix" home/users/chase/macbook-vm.nix
      7. Assert: match (imports LSP servers)
      8. grep "gui.nix\|hyprland\|zed.nix" home/users/chase/macbook-vm.nix
      9. Assert: no matches (no GUI imports)
      10. grep "extensions.zed" home/users/chase/macbook-vm.nix
      11. Assert: no match (option not available)
    Expected Result: Clean headless home config with dev tools + LSP servers
    Evidence: File contents
  ```

  **Commit**: NO (groups with Task 5)

---

- [x] 5. Update `flake.nix` with `nixosConfigurations.macbook-vm`

  **What to do**:
  - Add a new `nixosConfigurations.macbook-vm` block to `flake.nix` following the `nixosConfigurations.pc` pattern (lines 73-86)
  - Must include:
    - `determinate.nixosModules.default`
    - `./hosts/macbook-vm`
    - `nixpkgs.overlays` with `rust-overlay.overlays.default` and `foundry.overlay` (development.nix depends on rust-overlay for `pkgs.rust-bin`)
    - `inputs.home-manager.nixosModules.default`
  - Must NOT include:
    - `inputs.hyprland.nixosModules.default` (no Hyprland)

  **Exact addition** (after the `darwinConfigurations.macbook` block, before the closing `};`):

  ```nix
  nixosConfigurations.macbook-vm = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      determinate.nixosModules.default
      ./hosts/macbook-vm
      {
        nixpkgs.overlays = [
          rust-overlay.overlays.default
          foundry.overlay
        ];
      }
      inputs.home-manager.nixosModules.default
    ];
  };
  ```

  **Must NOT do**:
  - Modify the existing `nixosConfigurations.pc` or `darwinConfigurations.macbook` blocks
  - Add any new flake inputs
  - Change the `outputs` function signature
  - Add `system = "aarch64-linux"` — let orbstack.nix or the host config handle platform

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Skills Evaluated but Omitted**: None relevant

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential (after Tasks 3 + 4)
  - **Blocks**: Task 6
  - **Blocked By**: Tasks 3, 4

  **References**:

  **Pattern References**:
  - `flake.nix:73-86` — The `nixosConfigurations.pc` block. Follow this EXACT pattern for `macbook-vm`. Note line 76: `determinate.nixosModules.default`, lines 79-82: overlays, line 84: home-manager. The VM block should be structurally identical minus the hyprland module (which is in hosts/pc, not flake.nix anyway).
  - `flake.nix:88-102` — The `darwinConfigurations.macbook` block. The new block goes AFTER this one.
  - `flake.nix:62-71` — The outputs function signature. `self`, `determinate`, `nixpkgs`, `nix-darwin`, `rust-overlay`, `foundry` are destructured. All needed names are already available.

  **WHY Each Reference Matters**:
  - Lines 73-86 are the exact template to copy. Missing any module (especially overlays) will cause build failures.
  - Lines 88-102 mark where the new block should be inserted (after macbook, before closing braces).
  - Lines 62-71 confirm all needed inputs are already destructured — no changes needed to function args.

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: flake.nix has macbook-vm configuration
    Tool: Bash
    Preconditions: flake.nix updated
    Steps:
      1. grep "macbook-vm" flake.nix
      2. Assert: match found
      3. grep "nixosConfigurations.macbook-vm" flake.nix
      4. Assert: match found
      5. grep -A 15 "macbook-vm" flake.nix | grep "determinate"
      6. Assert: match (determinate module included)
      7. grep -A 15 "macbook-vm" flake.nix | grep "rust-overlay"
      8. Assert: match (overlay included)
      9. grep -A 15 "macbook-vm" flake.nix | grep "home-manager"
      10. Assert: match (home-manager included)
    Expected Result: Complete macbook-vm configuration entry in flake.nix
    Evidence: Relevant section of flake.nix shown

  Scenario: Existing configs unchanged
    Tool: Bash
    Preconditions: flake.nix updated
    Steps:
      1. grep "nixosConfigurations.pc" flake.nix
      2. Assert: match (PC still present)
      3. grep "darwinConfigurations.macbook" flake.nix
      4. Assert: match (macbook still present)
    Expected Result: No existing configs disturbed
    Evidence: flake.nix contents
  ```

  **Commit**: YES
  - Message: `feat(hosts): add macbook-vm NixOS configuration for OrbStack`
  - Files: `flake.nix`, `hosts/macbook-vm/default.nix`, `hosts/macbook-vm/orbstack.nix`, `home/users/chase/macbook-vm.nix`, `modules/nixos/1password-cli.nix`
  - Pre-commit: `nix flake check`

---

- [x] 6. Full verification — flake check + dry-build all configs + package assertions

  **What to do**:
  - Run comprehensive verification of all three configurations
  - This is the final gate before the work is considered complete

  **Verification steps:**

  1. `nix flake check` — must pass (exit 0)
  2. `nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run` — must pass
  3. `nix build .#darwinConfigurations.macbook.system --dry-run` — must pass
  4. `nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run` — must pass

  **If any fail**: Read the error, identify the issue, fix it, and re-verify. Common issues:
  - Missing overlay → add to flake.nix macbook-vm block
  - Duplicate option from orbstack.nix → remove from default.nix
  - `extensions.zed` referenced → remove from macbook-vm.nix
  - iptables conflict → create docker-vm.nix without firewall rules
  - Missing `nixpkgs.hostPlatform` → add `lib.mkDefault "aarch64-linux"` to hosts/macbook-vm/default.nix

  **Must NOT do**:
  - Skip any of the four verification commands
  - Accept partial success ("2 out of 3 build")
  - Modify orbstack.nix to fix issues (modify default.nix instead)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Skills Evaluated but Omitted**: None relevant

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 3 (final)
  - **Blocks**: None (final task)
  - **Blocked By**: Task 5

  **References**:

  **Pattern References**:
  - All files modified/created in Tasks 0-5
  - `flake.nix` — the entry point for all nix commands

  **WHY Each Reference Matters**:
  - This task is verification-only. If something fails, the executor needs to trace back to the relevant task's files.

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: All three configurations build successfully
    Tool: Bash
    Preconditions: All tasks 0-5 complete
    Steps:
      1. nix flake check 2>&1; echo "FLAKE_CHECK: $?"
      2. Assert: exit code 0
      3. nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run 2>&1; echo "PC_BUILD: $?"
      4. Assert: exit code 0
      5. nix build .#darwinConfigurations.macbook.system --dry-run 2>&1; echo "MAC_BUILD: $?"
      6. Assert: exit code 0
      7. nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run 2>&1; echo "VM_BUILD: $?"
      8. Assert: exit code 0
    Expected Result: All four commands succeed
    Failure Indicators: Non-zero exit codes, "error:" in output
    Evidence: Full output of all four commands

  Scenario: VM config has correct package composition
    Tool: Bash
    Preconditions: All builds pass
    Steps:
      1. Check VM has LSP packages (nil, nixd, rust-analyzer)
      2. Check VM does NOT have zed-editor or kitty
      3. Check PC still has zed-editor and kitty
    Expected Result: Clean separation of GUI vs headless packages
    Evidence: Package list evaluation output
  ```

  **Commit**: NO (only if fixes were needed; commit the fixes with descriptive message)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `refactor(home): extract GUI packages from base.nix into gui.nix and zed-lsp.nix` | `home/profiles/base.nix`, `home/profiles/gui.nix`, `home/programs/zed.nix`, `home/programs/zed-lsp.nix` | Files parse correctly |
| 2 | `refactor(home): add gui.nix import to pc and macbook user configs` | `home/users/chase/pc.nix`, `home/users/chase/macbook.nix` | `nix build --dry-run` for PC + macbook |
| 5 | `feat(hosts): add macbook-vm NixOS configuration for OrbStack` | `flake.nix`, `hosts/macbook-vm/default.nix`, `hosts/macbook-vm/orbstack.nix`, `home/users/chase/macbook-vm.nix`, `modules/nixos/1password-cli.nix` | `nix flake check` |

---

## Success Criteria

### Verification Commands
```bash
nix flake check                                                                    # Expected: exit 0
nix build .#nixosConfigurations.pc.config.system.build.toplevel --dry-run          # Expected: exit 0
nix build .#darwinConfigurations.macbook.system --dry-run                          # Expected: exit 0
nix build .#nixosConfigurations.macbook-vm.config.system.build.toplevel --dry-run  # Expected: exit 0
```

### Final Checklist
- [x] All "Must Have" present (LSP servers, docker, 1password CLI, dev tools, zsh, UID 1000, Rosetta)
- [x] All "Must NOT Have" absent (no zed-editor, no kitty, no Hyprland, no NVIDIA, no gaming, no audio, no boot.loader, no networkmanager)
- [x] All three configs build successfully (dry-run)
- [x] `nix flake check` passes
- [x] Existing PC and macbook configs unchanged in behavior (regression verified)
- [x] `orbstack.nix` is the real file from OrbStack, not fabricated
