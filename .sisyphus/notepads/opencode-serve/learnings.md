# Learnings - opencode-serve

## Conventions & Patterns
(Subagents append findings here)

## Task 2: Enable opencode serve in macbook-vm.nix

### Pattern: Adding serve config to existing extensions.opencode block
- Successfully merged `serve` config into existing `extensions.opencode` block
- Pattern: Add serve as nested attribute alongside pluginPath/configPath
- Package reference: `inputs.opencode.packages.${pkgs.system}.default` (copied from development.nix:27)

### Shell Alias Pattern
- Added `oc` alias to existing `home.shellAliases` block
- Command: `opencode attach http://localhost:4096 --dir $PWD`
- Note: `$PWD` is safe in shell aliases - expands at invocation time, not definition time

### Verification
- Nix eval passes with exit code 0
- Config evaluates to derivation: `/nix/store/90an6sm793l32lsbpzmw50hx1xiifqpl-nixos-system-macbook-vm-lxc-26.05.20260211.ec7c70d.drv`
- All config values match specification

### Function Args
- Required: `{ pkgs, inputs, ... }:` to access inputs.opencode and pkgs.system
- Pattern matches development.nix and other profiles

## Task 1: Extended opencode.nix with serve options and systemd service

### Patterns Applied
- **Option Declaration Pattern**: Followed existing pattern from lines 12-20 for new serve options
  - Used `lib.mkEnableOption` for boolean enable flag (auto-defaults to false)
  - Used `lib.types.port` for port number validation (0-65535)
  - Used `lib.types.package` for package reference (no default, must be set by consumer)
  
- **Config Merging Pattern**: Used `lib.mkMerge` to combine unconditional and conditional config
  - Existing activation script runs unconditionally (always copies config files)
  - New systemd service wrapped in `lib.mkIf cfg.serve.enable` (only on Linux when enabled)
  - This pattern ensures macOS compatibility (systemd.user.services ignored when condition false)

- **systemd Service Pattern**: Standard home-manager user service structure
  - `Unit.After = [ "default.target" ]` ensures service starts after user session
  - `Service.WorkingDirectory = "%h"` sets working dir to user home
  - `Service.Restart = "on-failure"` with `RestartSec = 5` provides resilience
  - `Install.WantedBy = [ "default.target" ]` enables service on login

### Key Decisions
- **No default for serve.package**: Intentionally omitted to force explicit configuration
  - Prevents accidental service enablement without proper package reference
  - Allows different configs to use different opencode builds (stable vs dev)

- **ExecStart uses full nix store path**: `${cfg.serve.package}/bin/opencode`
  - Ensures systemd uses exact nix-built binary (no PATH dependency)
  - Critical for reproducibility and avoiding version conflicts

- **Port default 4096**: Chosen to avoid common port conflicts
  - Above privileged range (1024+)
  - Not commonly used by other services
  - Easy to override via option

### Verification Success
- Nix evaluation passes with exit code 0
- No new evaluation errors introduced
- Module structure validated against specification
- All options correctly typed and documented


## 2026-02-16: Implemented opencode serve systemd service

### Implementation Pattern
- Extended `home/programs/opencode.nix` with three new options under `extensions.opencode.serve`:
  - `enable` (mkEnableOption)
  - `port` (mkOption with type port, default 4096)
  - `package` (mkOption with type package, no default)
- Used `lib.mkMerge` pattern to combine unconditional activation script with conditional systemd service
- Wrapped systemd service in `lib.mkIf cfg.serve.enable`
- Service configuration: Restart=on-failure, RestartSec=5, WorkingDirectory=%h

### macbook-vm.nix Configuration
- Added `pkgs` and `inputs` to function args
- Enabled serve with `extensions.opencode.serve.enable = true`
- Referenced package via `inputs.opencode.packages.${pkgs.system}.default`
- Added `oc` alias: `opencode attach http://localhost:4096 --dir $PWD`

### Verification
- Nix evaluation passed successfully
- Build created 4 derivations including opencode-serve.service
- Flake lock updated to include opencode input (github:anomalyco/opencode/v1.2.5)

### Key Learnings
- Must use full nix store path in ExecStart: `${cfg.serve.package}/bin/opencode serve --port ${toString cfg.serve.port}`
- lib.mkMerge allows combining unconditional and conditional config blocks cleanly
- systemd user services go in systemd.user.services namespace
- Port type ensures valid port numbers (0-65535)

## Task 3: Verification Results ($(date '+%Y-%m-%d %H:%M:%S'))

**Scenario 1: NixOS Rebuild**
- Status: BLOCKED
- Issue: Cannot execute sudo commands without password
- Evidence: `.sisyphus/evidence/task-3-rebuild.txt`
- Result: ❌ Rebuild not applied

**Scenario 2: systemd Service Status**
- Command: `systemctl --user status opencode-serve`
- Result: ❌ Unit not found (expected - rebuild not applied)
- Evidence: `.sisyphus/evidence/task-3-service-status.txt`

**Scenario 3: Port 4096 Listening**
- Command: `curl -sf http://localhost:4096`
- Result: ❌ Connection failed (HTTP code 000)
- Evidence: `.sisyphus/evidence/task-3-port-check.txt`

**Scenario 4: oc Alias**
- Command: `zsh -c 'type oc'`
- Result: ❌ Alias not found (expected - rebuild not applied)
- Evidence: `.sisyphus/evidence/task-3-oc-alias-test.txt`

**Scenario 5: Service Restart**
- Command: `systemctl --user restart opencode-serve`
- Result: ❌ Unit not found (expected - rebuild not applied)
- Evidence: `.sisyphus/evidence/task-3-restart-test.txt`

**Summary**:
All verification scenarios failed as expected because the NixOS rebuild could not be executed due to sudo password requirement. The configuration changes in tasks 1-2 are committed but not yet applied to the running system.

**Next Steps**:
1. User must manually run: `sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm`
2. Re-run verification scenarios to confirm service deployment
3. All evidence files saved for audit trail
