{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.hostSpec.yubikey {
  services = {
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
    yubikey-agent.enable = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
    age-plugin-yubikey
    pam_u2f
  ];
}
