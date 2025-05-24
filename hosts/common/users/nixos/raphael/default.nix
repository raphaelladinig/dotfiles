{
  pkgs,
  config,
  ...
} @ args: let
  username = "raphael";
in {
  imports = [
    (import ../../../templates/users/nixos/main.nix (args // {inherit username;}))
    ./school.nix
    ../../../yubikey.nix
    ../../../sudo.nix
    ../../../hyprland.nix
    ../../../ssh
    ../../../virtualisation.nix
  ];

  userSpec.raphael = {
    inherit username;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
      "networkmanager"
      "docker"
      "libvirtd"
    ];
    school = false;
    yubikey = config.hostSpec.yubikey;
    name = "Raphael Ladinig";
    email = "mail@raphaelladinig.com";
  };

  users.users.${username} = {
    openssh.authorizedKeys.keyFiles = [
      ../../../ssh/id_raphael.pub
    ];

    shell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;

  programs.zsh.enable = true;

  security.pam = {
    u2f = {
      enable = true;
      settings = {
        authfile = "/home/raphael/.config/Yubico/u2f_keys";
      };
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
  };

  environment.persistence."/persist" = {
    directories = [
      "/home/raphael"
      "/var/lib/bluetooth"
      "/var/lib/mysql"
    ];
  };

  programs.steam.package = pkgs.steam.override {
    extraPkgs = p: [
      p.bibata-cursors
    ];
  };
}
