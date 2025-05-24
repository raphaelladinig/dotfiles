{pkgs, ...}: {
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    qemu
    quickemu
    spice
  ];
}
