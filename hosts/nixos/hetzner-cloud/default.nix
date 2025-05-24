{
  imports = [
    ../../common/templates/hosts/nixos/vm
    ./disk-config.nix
    ../../common/agenix.nix
    ./syncthing.nix
  ];

  hostSpec = {
    hostName = "hetzner-cloud";
    agenixIdentityPaths = [
      "/var/lib/agenix/age_hetzner-cloud.txt"
    ];
  };
}
