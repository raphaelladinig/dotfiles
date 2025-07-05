{
  pkgs,
  config,
  ...
} @ args: let
  username = "raphael";
in {
  imports = [
    (import ../../../templates/users/nixos/simple.nix (args // {inherit username;}))
    ./school.nix
    ../../../yubikey.nix
    ../../../sudo.nix
    ../../../hyprland.nix
    ../../../ssh
    ../../../virtualisation.nix
    ../../../steam.nix
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
    users.raphael = {
      directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Public"
        "Templates"
        "Videos"

        "sync"
        "self"
        "school"
        "Dev"
        "VirtualMachines"
        
        ".zen"
        ".ssh"
        ".config/uwsm"
        ".local/state/wireplumber"
        ".local/share/zoxide"
        ".local/share/direnv"
        ".local/share/Steam"
        ".local/share/DaVinciResolve"
        ".local/share/nvim"
        ".local/state/nvim"
        ".local/state/lazygit"
        ".platformio"
      ];
      files = [
        ".zsh_history"
      ];
    };
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/mysql"
    ];
  };
}
