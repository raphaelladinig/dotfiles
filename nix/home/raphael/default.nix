{
  pkgs,
  ...
}: {
  imports = [
    ../common/templates/simple.nix
    ./yubikey
    ./git.nix
    ./school.nix
    ./ssh.nix
    ./syncthing.nix
    ./localsend.nix
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
    bluetuith
    gemini-cli
  ];
}
