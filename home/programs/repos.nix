{ config, lib, pkgs, ... }:
let
  cfg = config.custom.repos;
  homeDir = config.home.homeDirectory;
  gitExe = lib.getExe pkgs.git;
  sshExe = lib.getExe' pkgs.openssh "ssh";

  mkAbsPath = path: "${homeDir}/${path}";

  rootCommands = map (root: ''
    mkdir -p ${lib.escapeShellArg (mkAbsPath root)}
  '') cfg.roots;

  repoCommands = map (
    repo:
    let
      absPath = mkAbsPath repo.path;
      parentDir = dirOf absPath;
    in
    ''
      mkdir -p ${lib.escapeShellArg parentDir}

      if [ -d ${lib.escapeShellArg absPath} ]; then
        if [ ! -d ${lib.escapeShellArg "${absPath}/.git"} ]; then
          echo "repos.nix: skipping ${lib.escapeShellArg repo.path}; directory exists but is not a git repo" >&2
        fi
      elif [ "${if cfg.cloneMissingRepositories then "1" else "0"}" = "1" ]; then
        GIT_SSH_COMMAND=${lib.escapeShellArg sshExe} \
          ${gitExe} clone ${lib.escapeShellArg repo.remote} ${lib.escapeShellArg absPath}
      fi
    ''
  ) cfg.repositories;
  bootstrapScript = pkgs.writeShellScriptBin "bootstrap-repos" ''
    set -eu

    ${lib.concatStringsSep "\n" rootCommands}

    ${lib.concatStringsSep "\n" (
      map (
        repo:
        let
          absPath = mkAbsPath repo.path;
          parentDir = dirOf absPath;
        in
        ''
          mkdir -p ${lib.escapeShellArg parentDir}

          if [ -d ${lib.escapeShellArg absPath} ]; then
            if [ -d ${lib.escapeShellArg "${absPath}/.git"} ]; then
              echo "bootstrap-repos: already cloned ${lib.escapeShellArg repo.path}"
            else
              echo "bootstrap-repos: skipping ${lib.escapeShellArg repo.path}; directory exists but is not a git repo" >&2
            fi
          else
            GIT_SSH_COMMAND=${lib.escapeShellArg sshExe} \
              ${gitExe} clone ${lib.escapeShellArg repo.remote} ${lib.escapeShellArg absPath}
          fi
        ''
      ) cfg.repositories
    )}
  '';
in
{
  options.custom.repos = {
    enable = lib.mkEnableOption "declarative repository roots and optional clone bootstrap";

    roots = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "arcadia"
        "personal"
      ];
      description = "Directories created under the user's home directory for repo grouping.";
    };

    repositories = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              example = "personal/example-repo";
              description = "Repository path relative to the user's home directory.";
            };

            remote = lib.mkOption {
              type = lib.types.str;
              example = "git@github.com:Chasewhip8/example-repo.git";
              description = "Git remote cloned when the repository is missing locally.";
            };
          };
        }
      );
      default = [ ];
      description = "Repositories to clone if missing. Existing repositories are left untouched.";
    };

    cloneMissingRepositories = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Clone declared repositories when their target directory does not exist.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ bootstrapScript ];

    assertions = [
      {
        assertion = builtins.all (root: root != "" && !lib.hasPrefix "/" root) cfg.roots;
        message = "custom.repos.roots must be non-empty relative paths under home.homeDirectory.";
      }
      {
        assertion = builtins.all (
          repo: repo.path != "" && !lib.hasPrefix "/" repo.path && repo.remote != ""
        ) cfg.repositories;
        message = "custom.repos.repositories entries must have non-empty relative paths and remotes.";
      }
    ];

    home.activation.repoLayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -eu

      ${lib.concatStringsSep "\n" (rootCommands ++ repoCommands)}
    '';
  };
}
