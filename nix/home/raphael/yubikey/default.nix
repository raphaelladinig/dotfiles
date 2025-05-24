{
  hostSpec,
  lib,
  config,
  ...
}:
lib.mkIf config.homeSpec.yubikey {
  sops.secrets = {
    "yubi-identity" = {
      sopsFile = "${hostSpec.secretsPath}/age_yubi";
      path = ".age/age_yubi";
    };
    u2f_keys = {
      sopsFile = "${hostSpec.secretsPath}/u2f_keys";
      path = ".config/Yubico/u2f_keys";
    };
  };

  home.file = {
    ".age/yubi-recipient".source = ./yubi-recipient;
  };
}
