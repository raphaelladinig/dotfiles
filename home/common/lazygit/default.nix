{pkgs, ...}: {
  home.file = {
    ".config/lazygit".source = ./lazygit;
  };

  home.packages = with pkgs; [lazygit];
}
