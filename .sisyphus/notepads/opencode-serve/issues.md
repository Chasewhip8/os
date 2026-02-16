# Issues - opencode-serve

## Problems & Gotchas
(Subagents append findings here)

## Task 3: NixOS Rebuild Blocker ($(date '+%Y-%m-%d %H:%M:%S'))

**Issue**: Cannot execute `sudo nixos-rebuild switch` from automated task context

**Root Cause**: 
- Execution environment does not support interactive password prompts
- Passwordless sudo is not configured for user 'chase'
- `sudo -n` (non-interactive) fails with "a password is required"

**Impact**: 
- Cannot apply NixOS configuration changes automatically
- Cannot verify systemd service deployment
- Task 3 blocked until manual rebuild is performed

**Workarounds**:
1. User manually runs: `sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm`
2. Configure passwordless sudo for nixos-rebuild (security consideration required)
3. Use a different deployment mechanism that doesn't require sudo

**Status**: BLOCKED - awaiting manual intervention
