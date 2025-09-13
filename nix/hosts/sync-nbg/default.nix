{
  imports = [
    ../common/templates/hosts/sync
    ./disk-config.nix
  ];

  hostSpec = {
    hostName = "sync-nbg";
  };
}
