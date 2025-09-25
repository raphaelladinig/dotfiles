{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common/templates/simple.nix
    ./yubikey
    ./git.nix
    ./school.nix
    ./ssh.nix
    ./syncthing.nix
    ../common/hyprland
  ];

  home.packages = with pkgs; [
    fastfetch
    cryptsetup
    tokei
    tree
    gnumake
    just
    pandoc
    pavucontrol
    nodejs
    bun
    unzip
    zip
    home-manager
    pnpm
    sqlite
    docker-compose
    aider-chat
    zathura
  ];
}
