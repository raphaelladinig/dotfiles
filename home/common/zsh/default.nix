{
  pkgs,
  hostSpec,
  ...
}: {
  programs.zsh = {
    enable = true;

    plugins = [
      {
        name = "zsh-fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "zsh-fzf-tab";
        src = pkgs.zsh-fzf-tab;
      }
    ];
  };

  home.file = {
    ".zshrc".source = ./.zshrc;
  };

  imports = [
    ../starship
    ../lazygit
    ../neovim
    ../btop
    ../tmux
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nnn.enable = true;
  };

  home.packages = with pkgs; [
    fzf
    zoxide
  ];

  sops.secrets.GEMINI_API_KEY.sopsFile = "${hostSpec.secretsPath}/GEMINI_API_KEY";
}
