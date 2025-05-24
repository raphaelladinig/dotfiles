{pkgs, ...}: {
  home.file = {
    ".config/btop/btop.conf".source = ./btop.conf;
  };

  home.packages = with pkgs; [
    btop
  ];
}
