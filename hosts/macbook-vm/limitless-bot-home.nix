{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  bot = osConfig.local.features.limitlessBot;
  secrets = osConfig.local.secrets;
  githubTokenFile = secrets.limitlessBotGithubToken.path;
  gitCredentialHelper = pkgs.writeShellScript "limitless-bot-git-credential" ''
    set -eu

    if [ ! -r ${lib.escapeShellArg githubTokenFile} ]; then
      printf 'limitless-bot: GitHub token is not readable: %s\n' ${lib.escapeShellArg githubTokenFile} >&2
      exit 1
    fi

    GH_TOKEN="$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg githubTokenFile})"
    export GH_TOKEN
    exec ${pkgs.gh}/bin/gh auth git-credential "$@"
  '';
in
{
  imports = [
    ../../home/dev.nix
    ../../home/features/gh.nix
    inputs.limitless.homeModules.default
  ];

  home = {
    username = bot.userName;
    homeDirectory = bot.homeDirectory;
    stateVersion = "24.05";
    packages = [
      pkgs.docker-client
      pkgs.docker-compose
      pkgs.ripgrep
    ];
    sessionVariables = {
      DOCKER_CONFIG = "${bot.homeDirectory}/.config/docker";
      DOCKER_HOST = "unix:///opt/orbstack-guest/run/docker.sock";
    };
  };

  manual.manpages.enable = false;
  programs.bash.enable = true;
  programs.home-manager.enable = true;

  custom.gh = {
    enable = true;
    tokenFile = githubTokenFile;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Chasewhip8";
        email = "chasewhip20@gmail.com";
      };
      credential."https://github.com".helper = "!${gitCredentialHelper}";
      url."https://github.com/".insteadOf = "git@github.com:";
      init.defaultBranch = "main";
    };
  };

  programs.limitless = {
    enable = true;

    github = {
      enable = true;
      allowUnrestrictedRepos = false;
      tokenFile = githubTokenFile;
      allowedRepos = [
        "Arcadia-Financial/arcadia-wallet-gateway"
        "OpenZeppelin/openzeppelin-contracts"
        "Sphere-Financial/symmetry"
        "Sphere-Financial/titan-mexican-corridor"
        "Sphere-Laboratories/crypto"
        "Sphere-Laboratories/customers"
        "Sphere-Laboratories/error"
        "Sphere-Laboratories/events"
        "Sphere-Laboratories/logger"
        "Sphere-Laboratories/sentry"
        "Sphere-Laboratories/sft-dashboard-app"
        "Sphere-Laboratories/sft-frontend"
        "Sphere-Laboratories/sft-ui"
        "Sphere-Laboratories/sumsub-config-tooling"
        "Sphere-Laboratories/workspace"
        "a16z/erc4626-tests"
        "dapphub/ds-test"
        "foundry-rs/forge-std"
      ];
    };

    opencode = {
      disableClaudeCode = true;
      extraAgentsFile = ../../config/AGENTS.md;
      settings = builtins.fromJSON (builtins.readFile ../../config/opencode.json);
      service = {
        enable = true;
        hostname = "127.0.0.1";
        port = 4097;
        alias = "gary";
      };
    };

    slack = {
      enable = false;
      repository = bot.workspaceDirectory;
      agent = "gary";
      environmentFile = secrets.limitlessBotSlackEnvironment.path;
    };
  };

  systemd.user.services.opencode.Service.Environment = [
    "DOCKER_CONFIG=${bot.homeDirectory}/.config/docker"
    "DOCKER_HOST=unix:///opt/orbstack-guest/run/docker.sock"
  ];
}
