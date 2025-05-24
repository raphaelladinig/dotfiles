{pkgs, ...}: {
  imports = [
    ../common/templates/main.nix
    ./yubikey.nix
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
    htop
    gnumake
    just
    pandoc
    pavucontrol
    bluetuith
    davinci-resolve
    nodejs
    bun
    unzip
    zip
    home-manager
    pnpm
    sqlite
    docker-compose
  ];
}
