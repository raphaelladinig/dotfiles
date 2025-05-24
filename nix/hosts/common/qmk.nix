{pkgs, ...}: {
  hardware.keyboard.qmk.enable = true;

  services.udev.packages = with pkgs; [
    via
    qmk-udev-rules
  ];

  environment.systemPackages = with pkgs; [
    via
  ];
}
