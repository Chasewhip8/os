# Shared ZSH configuration
{ ... }:
{
  # Zsh theme
  home.file.".config/zsh/themes/enabled.zsh-theme".source = ./main.zsh-theme;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      source ~/.config/zsh/themes/enabled.zsh-theme
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
    };
  };
}
