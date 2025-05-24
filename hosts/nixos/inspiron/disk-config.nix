{
  imports = [../../common/templates/hosts/nixos/main/disk-config.nix];

  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-CT1000P1SSD8_20452B5DC42B";
    };
  };
}
