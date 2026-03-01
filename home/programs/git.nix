# Shared Git configuration
{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Chasewhip8";
    userEmail = "chasewhip20@gmail.com";
    ignores = [
      # OS
      ".DS_Store"
      "Thumbs.db"

      # Environment
      ".env"
      ".env.local"
      ".env.*.local"

      # Nix
      "result"
      "result-*"

      # AI
      ".sisyphus"
      "worktrees"
    ];
  };
}
