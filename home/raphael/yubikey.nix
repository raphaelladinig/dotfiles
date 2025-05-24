{
  hostSpec,
  lib,
  config,
  ...
}:
lib.mkIf config.homeSpec.yubikey {
  age.secrets.u2f_keys = {
    file = "${hostSpec.secretsPath}/u2f_keys.age";
    path = ".config/Yubico/u2f_keys";
  };
}
