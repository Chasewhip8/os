# opencode serve as a systemd user service + `oc` attach alias

## TL;DR

> **Quick Summary**: Add a systemd user service running `opencode serve --port 4096` on the NixOS VM, with an `oc` shell alias that attaches to it using the current working directory.
> 
> **Deliverables**:
> - Extended `opencode.nix` module with `serve.enable` / `serve.port` options and a guarded systemd user service
> - `oc` shell alias in VM user config that runs `opencode attach --dir $PWD`
> 
> **Estimated Effort**: Quick
> **Parallel Execution**: YES - 2 waves (but tasks are small enough to be near-sequential)
> **Critical Path**: Task 1 (module) → Task 2 (enable + alias) → Task 3 (verify)

---

## Context

### Original Request
Run `opencode serve` as a service inside the NixOS VM. Have an `oc` alias that opens opencode via attach functionality to the server, passing the current directory.

### Interview Summary
**Key Discussions**:
- **Service type**: User-level systemd service via home-manager `systemd.user.services` (starts with user session, aligns with opencode being a user-level tool)
- **Port**: Fixed at 4096 for reliable alias targeting
- **Scope**: VM-only (`macbook-vm` host)

### Metis Review
**Identified Gaps** (addressed):
- **`opencode.nix` is imported by ALL hosts** (via `base.nix`): Service config MUST be guarded with `mkEnableOption` + `mkIf` to avoid breaking macOS or PC builds
- **Package reference in ExecStart**: Module needs the opencode package passed in — use a `serve.package` option since the module doesn't currently have `inputs` in scope, and lazy evaluation under `mkIf false` means it's never demanded on hosts where it's not enabled
- **Restart policy**: Add `Restart=on-failure` + `RestartSec=5` for resilience
- **WorkingDirectory**: Set to `%h` (user home) — `attach --dir` controls the project context
- **Auth is file-based**: OAuth tokens stored at `~/.local/share/opencode/auth.json` — user-level service has access, no env var concern
- **`$PWD` in alias is safe**: Shell aliases are textual substitutions — `$PWD` expands at invocation time after alias expansion, not at definition time

---

## Work Objectives

### Core Objective
Enable `opencode serve` as a persistent background service on the NixOS VM, accessible via a short `oc` command from any directory.

### Concrete Deliverables
- `home/programs/opencode.nix` — extended with `serve.enable`, `serve.port`, `serve.package` options + guarded `systemd.user.services.opencode-serve`
- `home/users/chase/macbook-vm.nix` — enables the service and adds `oc` shell alias

### Definition of Done
- [ ] `nixos-rebuild switch` succeeds on macbook-vm
- [ ] `systemctl --user status opencode-serve` shows `active (running)`
- [ ] `curl -sf http://localhost:4096` returns a response
- [ ] `oc` command launches opencode TUI attached to the server
- [ ] No breakage on other hosts (macOS/PC configs still evaluate without errors)

### Must Have
- `mkEnableOption` guard — service only activates when explicitly enabled
- Fixed port 4096 in service config
- `Restart=on-failure` with `RestartSec=5`
- `oc` alias passes current directory via `--dir $PWD`

### Must NOT Have (Guardrails)
- Do NOT add service management aliases (`oc-restart`, `oc-status`, etc.) — out of scope
- Do NOT add health checks, liveness probes, or monitoring
- Do NOT add `OPENCODE_SERVER_PASSWORD` or any auth layer (localhost-only is sufficient)
- Do NOT add socket activation or other systemd complexity
- Do NOT modify `base.nix`, `development.nix`, `macbook.nix`, or `pc.nix`
- Do NOT refactor existing `opencode.nix` option structure (keep `pluginPath`/`configPath` as-is)
- Do NOT add log rotation or journal configuration

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: N/A (NixOS configuration, not application code)
- **Automated tests**: None (verified by rebuild + systemctl + curl)
- **Framework**: N/A

### QA Policy
Every task includes agent-executed QA scenarios verified via tmux and bash commands.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

| Deliverable Type | Verification Tool | Method |
|------------------|-------------------|--------|
| NixOS module | Bash | `nixos-rebuild switch`, `nix eval` |
| systemd service | Bash | `systemctl --user status`, `curl` |
| Shell alias | interactive_bash (tmux) | Type `oc`, verify TUI launches |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — both file edits are independent):
├── Task 1: Extend opencode.nix module with serve options + systemd service [quick]
├── Task 2: Enable service + add oc alias in macbook-vm.nix [quick]

Wave 2 (After Wave 1 — rebuild and verify):
└── Task 3: Apply NixOS rebuild and verify everything works [quick]

Wave FINAL (After ALL tasks — independent review):
└── Task F1: Scope fidelity check [quick]

Critical Path: Task 1 + Task 2 (parallel) → Task 3 → F1
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|------------|--------|------|
| 1 | — | 3 | 1 |
| 2 | — | 3 | 1 |
| 3 | 1, 2 | F1 | 2 |
| F1 | 3 | — | FINAL |

### Agent Dispatch Summary

| Wave | # Parallel | Tasks → Agent Category |
|------|------------|----------------------|
| 1 | **2** | T1 → `quick`, T2 → `quick` |
| 2 | **1** | T3 → `quick` |
| FINAL | **1** | F1 → `quick` |

---

## TODOs

- [x] 1. Extend opencode.nix module with serve options and systemd user service

  **What to do**:
  - Add three new options under `extensions.opencode.serve`:
    - `enable` — `lib.mkEnableOption "opencode headless server"`
    - `port` — `lib.mkOption { type = lib.types.port; default = 4096; description = "Port for opencode serve"; }`
    - `package` — `lib.mkOption { type = lib.types.package; description = "The opencode package to use for the server"; }`
  - Add a `lib.mkIf cfg.serve.enable` block in the `config` section containing:
    ```
    systemd.user.services.opencode-serve = {
      Unit = {
        Description = "OpenCode headless server";
        After = [ "default.target" ];
      };
      Service = {
        ExecStart = "${cfg.serve.package}/bin/opencode serve --port ${toString cfg.serve.port}";
        Restart = "on-failure";
        RestartSec = 5;
        WorkingDirectory = "%h";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    ```
  - The existing `config` block with `home.activation.opencodeResetConfig` runs unconditionally — leave it as-is. Add the new `mkIf` block alongside it using `lib.mkMerge` or by restructuring config as: `config = { home.activation... } // lib.mkIf cfg.serve.enable { systemd.user.services... }`

  **Must NOT do**:
  - Do NOT change the existing `pluginPath` / `configPath` options or the activation script
  - Do NOT add a default value for `serve.package` (it must be explicitly set by enabling configs)
  - Do NOT add `Environment` directives for API keys (auth is file-based)
  - Do NOT use bare `opencode` in ExecStart — must be full nix store path via `${cfg.serve.package}/bin/opencode`

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single-file edit, well-defined Nix module pattern, <30 lines of new code
  - **Skills**: []
    - No special skills needed — standard Nix module editing
  - **Skills Evaluated but Omitted**:
    - `playwright`: No browser interaction needed
    - `git-master`: No git operations in this task

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: Task 3
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL):

  **Pattern References** (existing code to follow):
  - `home/programs/opencode.nix:1-35` — The entire existing module. Follow the `cfg = config.extensions.opencode` pattern. New options go inside `extensions.opencode.serve.*`. The module uses `{ config, lib, ... }:` args — no changes needed to function args.
  - `home/programs/opencode.nix:10-21` — Option declaration pattern using `lib.mkOption` with `type` and `description` fields. Follow this exact style for new options.
  - `home/programs/opencode.nix:24-33` — Config section pattern. The new `systemd.user.services` block must coexist with the existing `home.activation` block.

  **API/Type References**:
  - `lib.mkEnableOption` — Creates a boolean option with `default = false`. Usage: `serve.enable = lib.mkEnableOption "opencode headless server";`
  - `lib.types.port` — Nix type for port numbers (integer 0-65535)
  - `lib.types.package` — Nix type for derivations/packages
  - `lib.mkIf` — Conditional config application. Prevents evaluation of service block when `serve.enable = false`

  **External References**:
  - home-manager `systemd.user.services` option: creates systemd user unit files with `Unit`, `Service`, `Install` sections

  **WHY Each Reference Matters**:
  - `opencode.nix:1-35` — This IS the file being modified. Understand its complete current state before editing.
  - `lib.mkEnableOption` — CRITICAL for the macOS safety guard. Without this, enabling this module on macOS (which has no systemd) would break the build.
  - `lib.types.package` — The `serve.package` option type. No default means it must be set explicitly, but since it's only referenced inside `mkIf cfg.serve.enable`, it's safe.

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Module evaluates without errors (nix eval)
    Tool: Bash
    Preconditions: Working nix installation, current flake
    Steps:
      1. Run: nix eval .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-build 2>&1
      2. Check exit code is 0
    Expected Result: No evaluation errors. Exit code 0.
    Failure Indicators: Nix evaluation error mentioning opencode, serve, or systemd
    Evidence: .sisyphus/evidence/task-1-nix-eval.txt

  Scenario: Module options are correctly defined
    Tool: Bash
    Preconditions: Task 1 changes applied to opencode.nix
    Steps:
      1. Read the modified opencode.nix file
      2. Verify `extensions.opencode.serve.enable` option exists with mkEnableOption
      3. Verify `extensions.opencode.serve.port` option exists with type port and default 4096
      4. Verify `extensions.opencode.serve.package` option exists with type package
      5. Verify systemd service block is wrapped in `lib.mkIf cfg.serve.enable`
      6. Verify ExecStart uses `${cfg.serve.package}/bin/opencode serve --port ${toString cfg.serve.port}`
      7. Verify Restart=on-failure and RestartSec=5 are set
    Expected Result: All option declarations and service config match specification
    Failure Indicators: Missing options, missing mkIf guard, bare `opencode` in ExecStart
    Evidence: .sisyphus/evidence/task-1-module-review.txt
  ```

  **Commit**: YES (groups with Task 2)
  - Message: `feat(opencode): add serve systemd user service + oc alias`
  - Files: `home/programs/opencode.nix`, `home/users/chase/macbook-vm.nix`
  - Pre-commit: `nix eval .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-build`

---

- [x] 2. Enable opencode serve and add `oc` alias in macbook-vm.nix

  **What to do**:
  - Add `pkgs` and `inputs` to the module function args: `{ pkgs, inputs, ... }:`
  - Add `extensions.opencode.serve` config:
    ```
    extensions.opencode.serve = {
      enable = true;
      package = inputs.opencode.packages.${pkgs.system}.default;
    };
    ```
    (port defaults to 4096 from the module, no need to set explicitly)
  - Add `oc` to `home.shellAliases`:
    ```
    oc = "opencode attach http://localhost:4096 --dir $PWD";
    ```
    Note: `$PWD` is safe in shell aliases — aliases are textual substitutions, so `$PWD` expands at invocation time when the substituted text is evaluated, not at definition time.

  **Must NOT do**:
  - Do NOT add aliases to any other user config (macbook.nix, pc.nix)
  - Do NOT add extra aliases like `oc-restart`, `oc-logs`, etc.
  - Do NOT hardcode the port in the alias if it differs from the option default — but since we're using 4096 everywhere, this is fine
  - Do NOT modify the existing `extensions.opencode.pluginPath`/`configPath` settings

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single-file edit, 5-6 lines of additions, straightforward Nix config
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - None relevant

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: Task 3
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL):

  **Pattern References**:
  - `home/users/chase/macbook-vm.nix:1-26` — The entire file being modified. Understand current structure: imports, home settings, extensions config, shellAliases.
  - `home/users/chase/macbook-vm.nix:14-17` — Existing `extensions.opencode` usage pattern. New `serve` options nest under this same namespace.
  - `home/users/chase/macbook-vm.nix:22-25` — Existing `home.shellAliases` block. Add `oc` here alongside existing aliases.
  - `home/profiles/development.nix:27` — Shows how the opencode package is referenced: `inputs.opencode.packages.${pkgs.system}.default`. Use the same reference for `serve.package`.

  **API/Type References**:
  - `inputs.opencode.packages.${pkgs.system}.default` — The opencode package derivation from the flake input. Available via `extraSpecialArgs = { inherit inputs; }` in `hosts/macbook-vm/default.nix:35`.

  **WHY Each Reference Matters**:
  - `macbook-vm.nix:1-26` — This IS the file being modified. Must understand the complete current state.
  - `macbook-vm.nix:14-17` — Shows the existing `extensions.opencode` block — new `serve` config goes alongside or merged with this.
  - `development.nix:27` — Shows the EXACT package reference syntax to copy for `serve.package`.

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: VM config evaluates without errors
    Tool: Bash
    Preconditions: Both Task 1 and Task 2 changes applied
    Steps:
      1. Run: nix eval .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-build 2>&1
      2. Check exit code is 0
    Expected Result: No evaluation errors. Exit code 0.
    Failure Indicators: Nix evaluation error mentioning undefined variable, missing attribute, or type mismatch
    Evidence: .sisyphus/evidence/task-2-nix-eval.txt

  Scenario: Config values are correctly set
    Tool: Bash
    Preconditions: Task 2 changes applied to macbook-vm.nix
    Steps:
      1. Read the modified macbook-vm.nix file
      2. Verify function args include `pkgs` and `inputs`
      3. Verify `extensions.opencode.serve.enable = true` is present
      4. Verify `extensions.opencode.serve.package` references `inputs.opencode.packages.${pkgs.system}.default`
      5. Verify `home.shellAliases` contains `oc` with `opencode attach http://localhost:4096 --dir $PWD`
    Expected Result: All config values match specification
    Failure Indicators: Missing args, wrong package reference, alias missing or malformed
    Evidence: .sisyphus/evidence/task-2-config-review.txt
  ```

  **Commit**: YES (groups with Task 1)
  - Message: `feat(opencode): add serve systemd user service + oc alias`
  - Files: `home/programs/opencode.nix`, `home/users/chase/macbook-vm.nix`
  - Pre-commit: `nix eval .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-build`

---

- [ ] 3. Apply NixOS rebuild and verify service + alias

  **What to do**:
  - Run `sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm` to apply the configuration
  - Verify the systemd user service is running
  - Verify the port is listening
  - Verify the `oc` alias exists and launches correctly
  - If rebuild fails, diagnose and fix the Nix configuration errors

  **Must NOT do**:
  - Do NOT modify any files outside of fixing build errors found during verification
  - Do NOT add extra configuration not specified in the plan
  - Do NOT skip any verification step

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Running commands and checking output — no complex logic
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `playwright`: No browser interaction
    - `dev-browser`: No web browsing needed

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2 (sequential after Wave 1)
  - **Blocks**: F1
  - **Blocked By**: Task 1, Task 2

  **References** (CRITICAL):

  **Pattern References**:
  - `home/users/chase/macbook-vm.nix:23` — The existing `nixconf-apply` alias shows the exact rebuild command: `sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm`

  **WHY Each Reference Matters**:
  - `macbook-vm.nix:23` — Contains the exact rebuild command to use. Don't guess the flake reference.

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: NixOS rebuild succeeds
    Tool: Bash
    Preconditions: Tasks 1 and 2 completed, changes committed or staged
    Steps:
      1. Run: sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm 2>&1
      2. Check exit code is 0
    Expected Result: Rebuild completes successfully with exit code 0
    Failure Indicators: Build errors, evaluation errors, activation script failures
    Evidence: .sisyphus/evidence/task-3-rebuild.txt

  Scenario: systemd user service is running
    Tool: Bash
    Preconditions: Rebuild completed successfully
    Steps:
      1. Run: systemctl --user status opencode-serve 2>&1
      2. Verify output contains "active (running)"
      3. Verify output shows correct ExecStart with --port 4096
    Expected Result: Service is active and running on port 4096
    Failure Indicators: "inactive", "failed", "not found", wrong port
    Evidence: .sisyphus/evidence/task-3-service-status.txt

  Scenario: Port 4096 is listening and responding
    Tool: Bash
    Preconditions: Service is running
    Steps:
      1. Run: curl -sf http://localhost:4096 -o /dev/null -w "%{http_code}" 2>&1
      2. Verify HTTP response is received (any status code — even 404 means the server is up)
    Expected Result: HTTP response received (server is listening)
    Failure Indicators: "Connection refused", timeout, no response
    Evidence: .sisyphus/evidence/task-3-port-check.txt

  Scenario: oc alias exists and attaches to server
    Tool: interactive_bash (tmux)
    Preconditions: Service is running, new shell session (to pick up alias)
    Steps:
      1. Create new tmux session: new-session -d -s oc-test
      2. Start a fresh zsh shell: send-keys -t oc-test "zsh" Enter
      3. Wait 2 seconds for shell init
      4. Change to /tmp for testing: send-keys -t oc-test "cd /tmp" Enter
      5. Run: send-keys -t oc-test "type oc" Enter
      6. Wait 1 second, capture output
      7. Verify output shows the alias definition with "opencode attach"
      8. Run: send-keys -t oc-test "oc" Enter
      9. Wait 3 seconds for TUI to launch
      10. Capture screenshot of tmux pane
      11. Send Ctrl-C to exit: send-keys -t oc-test C-c
      12. Clean up: kill-session -t oc-test
    Expected Result: `type oc` shows the alias. `oc` launches opencode TUI attached to the server.
    Failure Indicators: "oc: not found", "Connection refused", TUI doesn't appear
    Evidence: .sisyphus/evidence/task-3-oc-alias-test.txt

  Scenario: Service survives restart (on-failure policy)
    Tool: Bash
    Preconditions: Service is running
    Steps:
      1. Run: systemctl --user restart opencode-serve
      2. Wait 3 seconds
      3. Run: systemctl --user status opencode-serve 2>&1
      4. Verify "active (running)"
    Expected Result: Service restarts cleanly and is running
    Failure Indicators: "failed", "inactive"
    Evidence: .sisyphus/evidence/task-3-restart-test.txt
  ```

  **Commit**: NO (verification only, no file changes expected)

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

- [x] F1. **Scope Fidelity Check** — `quick`
  Read the plan. For each "Must Have": verify implementation exists. For each "Must NOT Have": verify nothing extra was added. Check that ONLY `home/programs/opencode.nix` and `home/users/chase/macbook-vm.nix` were modified. Verify no changes leaked to `base.nix`, `development.nix`, `macbook.nix`, or `pc.nix`.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Files [2 modified] | VERDICT: APPROVE/REJECT`

---

## Commit Strategy

| After Tasks | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 + 2 | `feat(opencode): add serve systemd user service + oc alias` | `home/programs/opencode.nix`, `home/users/chase/macbook-vm.nix` | `nix eval .#nixosConfigurations.macbook-vm.config.system.build.toplevel --no-build` |

---

## Success Criteria

### Verification Commands
```bash
# Service running
systemctl --user status opencode-serve  # Expected: active (running)

# Port listening  
curl -sf http://localhost:4096 -o /dev/null -w "%{http_code}"  # Expected: HTTP response

# Alias defined
type oc  # Expected: oc is an alias for opencode attach http://localhost:4096 --dir $PWD

# Config builds cleanly
sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm  # Expected: exit code 0
```

### Final Checklist
- [ ] `opencode serve` runs as systemd user service on port 4096
- [ ] Service has `Restart=on-failure` with `RestartSec=5`
- [ ] `oc` alias attaches to server with current directory
- [ ] Module is guarded with `mkEnableOption` — disabled by default
- [ ] No changes to base.nix, development.nix, macbook.nix, or pc.nix
- [ ] NixOS rebuild succeeds
