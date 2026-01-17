# Plan: Multi-System Nix Configuration

## Current Structure Analysis

```
os/
├── flake.nix                    # Single nixosConfigurations.default output
├── hosts/default/
│   ├── configuration.nix        # All system config here
│   └── hardware-configuration.nix
├── modules/
│   ├── nvidia.nix               # NixOS-only (Linux GPU)
│   ├── greetd.nix               # NixOS-only (Linux display manager)
│   ├── files.nix                # NixOS-only (Thunar file manager)
│   ├── home-manager-lifted.nix  # NixOS-only (PAM/dconf)
│   └── home-manager/
│       ├── hyprland/            # Linux-only (Wayland compositor)
│       ├── zed.nix              # Cross-platform
│       └── solana.nix           # Cross-platform
└── users/chase/
    ├── home.nix                 # Tightly coupled to Linux
    ├── hyprland.nix             # Linux-only
    └── theme.nix                # Mostly cross-platform (GTK is Linux)
```

## Structural Issues

### 1. No Platform Separation

All modules are implicitly Linux-specific. There's no distinction between:

- Cross-platform modules (editors, CLI tools, shell config)
- Linux-only modules (Hyprland, NVIDIA, greetd)
- macOS-only modules (homebrew casks, macOS defaults)

### 2. Single Host Configuration

`flake.nix` only outputs `nixosConfigurations.default`. No structure for:

- `darwinConfigurations` for macOS
- Multiple hosts with shared modules

### 3. Home-Manager Coupling

`users/chase/home.nix` directly imports Linux-specific modules (hyprland). This won't work on macOS.

### 4. Hardcoded System Assumptions

- `hardware-configuration.nix` references specific hardware
- NVIDIA module assumes Linux kernel
- Hyprland modules assume Wayland (Linux-only)

---

## Proposed New Structure

```
os/
├── flake.nix                      # Multiple outputs: nixos + darwin
├── hosts/
│   ├── pc/                        # NixOS desktop (current "default")
│   │   ├── default.nix            # System configuration
│   │   └── hardware-configuration.nix
│   └── macbook/                   # macOS laptop
│       └── default.nix            # Darwin configuration
├── modules/
│   ├── nixos/                     # NixOS-only system modules
│   │   ├── nvidia.nix
│   │   ├── greetd.nix
│   │   ├── files.nix
│   │   └── hyprland.nix           # System-level Hyprland
│   ├── darwin/                    # macOS-only system modules
│   │   ├── homebrew.nix           # Homebrew package management
│   │   ├── defaults.nix           # macOS system defaults
│   │   └── aerospace.nix          # Window manager (or yabai)
│   └── shared/                    # Cross-platform system modules
│       └── nix-settings.nix       # Common nix config
├── home/
│   ├── profiles/
│   │   ├── base.nix               # Core: shell, git, CLI tools
│   │   ├── development.nix        # Dev tools: languages, editors
│   │   └── desktop.nix            # GUI apps (platform-aware)
│   ├── programs/                  # Individual program configs
│   │   ├── zsh.nix                # Cross-platform
│   │   ├── git.nix                # Cross-platform
│   │   ├── zed.nix                # Cross-platform
│   │   ├── kitty.nix              # Cross-platform
│   │   └── hyprland/              # Linux-only
│   │       ├── default.nix
│   │       ├── lock.nix
│   │       └── ...
│   └── users/
│       └── chase/
│           ├── default.nix        # User entry point (imports profiles)
│           ├── pc.nix             # PC-specific home config
│           └── macbook.nix        # Mac-specific home config
└── lib/
    └── helpers.nix                # Shared helper functions
```

---

## Migration Steps

### Phase 1: Reorganize Modules by Platform

1. Create `modules/nixos/` directory
2. Move Linux-specific modules:
    - `modules/nvidia.nix` → `modules/nixos/nvidia.nix`
    - `modules/greetd.nix` → `modules/nixos/greetd.nix`
    - `modules/files.nix` → `modules/nixos/files.nix`
    - `modules/home-manager-lifted.nix` → `modules/nixos/home-manager-lifted.nix`

3. Create `modules/darwin/` directory (empty for now)

4. Create `modules/shared/` for cross-platform system settings

### Phase 2: Restructure Home-Manager

1. Create `home/` directory structure:
    - `home/profiles/` - composable feature sets
    - `home/programs/` - individual program configs
    - `home/users/chase/` - user-specific configs

2. Extract cross-platform configs from `users/chase/home.nix`:
    - Shell configuration (zsh, starship, aliases)
    - Git configuration
    - CLI tools (ripgrep, fzf, zoxide, etc.)
    - Editors (zed, neovim if any)

3. Move Linux-specific home configs:
    - `modules/home-manager/hyprland/` → `home/programs/hyprland/`
    - `users/chase/hyprland.nix` → `home/users/chase/pc.nix`

4. Create profile system:
    - `base.nix` - always included (shell, git, core tools)
    - `development.nix` - programming languages, dev tools
    - `desktop.nix` - GUI applications (with platform conditionals)

### Phase 3: Rename Host and Update Flake

1. Rename `hosts/default/` → `hosts/pc/`

2. Update `flake.nix` to:
    - Add `nix-darwin` input
    - Create helper functions for building systems
    - Output both `nixosConfigurations.pc` and `darwinConfigurations.macbook`
    - Pass `pkgs.stdenv.isDarwin` / `isLinux` for conditional imports

3. Update `hosts/pc/default.nix` (renamed from configuration.nix) to use new module paths
