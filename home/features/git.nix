# Shared Git configuration
{ config, ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = config.local.user.git.name;
      email = config.local.user.git.email;
    };
    settings.url."git@github.com:".insteadOf = "https://github.com/";
    ignores = [
      # OS
      ".DS_Store"
      "Thumbs.db"

      # Environment
      ".env"
      ".env.local"
      ".env.*.local"
      ".envrc"

      # Nix
      "result"
      "result-*"

      # AI
      ".sisyphus"
      "worktrees"
    ];
  };
}
