{
  pkgs,
  config,
  ...
} @ args: let
  username = "raphael";
in {
  imports = [
    (import ../../templates/users/simple.nix (args // {inherit username;}))
    ./school.nix
    ../../yubikey.nix
    ../../sudo.nix
    ../../hyprland.nix
    ../../ssh
    ../../virtualisation.nix
    ../../qmk.nix
  ];

  "userSpec-${username}" = {
    inherit username;
    extraGroups =
      [
        "wheel"
        "video"
        "audio"
        "input"
        "networkmanager"
        "docker"
        "libvirtd"
      ]
      ++ (
        if config."userSpec-${username}".scanning
        then [
          "scanner"
          "lp"
        ]
        else []
      );
    school = false;
    yubikey = config.hostSpec.yubikey;
    name = "Raphael Ladinig";
    email = "mail@raphaelladinig.com";
  };

  users.users.${username} = {
    openssh.authorizedKeys.keyFiles = [
      ../../ssh/ssh_raphael.pub
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

        "Sync"

        "Dev"
        "VirtualMachines"

        ".ssh"
        ".zen"
        ".cache/zen"
        ".config/uwsm"
        ".local/state/wireplumber"
        ".local/state/syncthing"
        ".local/share/zoxide"
        ".local/share/direnv"
        ".local/share/DaVinciResolve"
        ".local/share/nvim"
        ".local/state/nvim"
        ".cache/nvim"
        ".local/state/lazygit"

        ".platformio"
        ".config/JetBrains"
        ".cache/JetBrains"
        ".local/share/JetBrains"
        ".config/tapyre"
        ".local/share/tapyre"
        ".wine"
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
