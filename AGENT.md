# Nix Configuration Agent Instructions

## Core Principle: Separation of Concerns

This configuration uses [Determinate Nix](https://docs.determinate.systems/) with flakes. Maintain strict modularity - no spaghetti code.

## Architecture Rules

### 1. Directory Boundaries

```
hosts/           → System-level config only (per-machine)
modules/nixos/   → NixOS-specific system modules
modules/darwin/  → macOS-specific system modules (create if needed)
home/profiles/   → Composable feature sets (cross-platform)
home/programs/   → Individual application configs
home/users/      → Per-user, per-host configurations
lib/             → Shared utility functions
```

### 2. Module Guidelines

**One concern per file.** If a module does two unrelated things, split it.

- System modules (`modules/`) configure system services, hardware, PAM
- Home modules (`home/programs/`) configure user applications
- Never mix system and user configuration in the same file
- Each module should be independently toggleable

**Bad:**

```nix
# nvidia-and-gaming.nix - DON'T DO THIS
{ services.xserver.videoDrivers = ["nvidia"]; programs.steam.enable = true; }
```

**Good:**

```nix
# nvidia.nix
{ services.xserver.videoDrivers = ["nvidia"]; }
# steam.nix (separate file)
{ programs.steam.enable = true; }
```

### 3. Import Hierarchy

```
flake.nix
  └─ hosts/{machine}/default.nix
       └─ modules/nixos/*.nix (system modules)
       └─ home-manager
            └─ home/users/{user}/{host}.nix
                 └─ home/profiles/*.nix
                 └─ home/programs/*.nix
```

- Hosts import modules, never the reverse
- Profiles compose programs, not system config
- Users import profiles, override as needed

### 4. Platform Separation

- Linux-only code: `modules/nixos/`, `home/programs/hyprland/`
- macOS-only code: `modules/darwin/`, macOS-specific in user configs
- Cross-platform code: `home/profiles/base.nix`, `home/profiles/development.nix`

Never use `if pkgs.stdenv.isDarwin` inline - create platform-specific files.

### 5. Avoiding Spaghetti

**DO:**

- Create a new file when adding a new application/service
- Use `imports = [ ]` to compose functionality
- Define custom options for configurable modules (see `home/programs/zed.nix`)
- Keep files under 100 lines; split if larger

**DON'T:**

- Add unrelated config to existing files for convenience
- Create circular imports
- Hardcode paths - use `config.home.homeDirectory`, `pkgs.lib`, etc.
- Duplicate configuration across hosts - extract to a module

## Reference Documentation

- [Determinate Nix Installer](https://docs.determinate.systems/nix-installer/)
- [Flakes Reference](https://docs.determinate.systems/flakes/)
- [Zero to Nix](https://zero-to-nix.com/) - Determinate's Nix guide
- [NixOS Options Search](https://search.nixos.org/options)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [nix-darwin Options](https://daiderd.com/nix-darwin/manual/index.html)

## Checklist Before Committing

- [ ] New functionality in its own file?
- [ ] File under 100 lines? Unless needed.
- [ ] No cross-layer imports (home importing system modules)?
- [ ] Platform-specific code in platform-specific directory?
- [ ] Can the module be disabled without breaking others?
