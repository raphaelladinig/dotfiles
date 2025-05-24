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
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nnn = {
      enable = true;
      plugins.src =
        (pkgs.fetchFromGitHub {
          owner = "jarun";
          repo = "nnn";
          rev = "v5.1";
          sha256 = "sha256-+2lFFBtaqRPBkEspCFtKl9fllbSR5MBB+4ks3Xh7vp4=";
        })
        + "/plugins";
    };
  };

  home.packages = with pkgs; [
    fzf
    zoxide
  ];

  age.secrets.GEMINI_API_KEY = {
    file = "${hostSpec.secretsPath}/GEMINI_API_KEY.age";
    path = ".config/agenix/GEMINI_API_KEY";
  };
}
