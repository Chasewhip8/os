# Homebrew casks (macOS GUI apps not available via Nix)
{ ... }:
{
  homebrew = {
    enable = true;
    taps = [
      "nikitabobko/tap"
    ];
    casks = [
      "1password"
      "aerospace"
      "discord"
      "google-chrome"
      "kitty"
      "notion"
      "slack"
      "telegram"
      "zed"
    ];
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
  };
}
