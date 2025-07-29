{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = config.homeSpec.sopsAgeKeyFile;
    defaultSopsFormat = "binary";
    secrets = {
      age_yubi.sopsFile = "${config.homeSpec.secretsPath}/age_yubi";
      age_biyu.sopsFile = "${config.homeSpec.secretsPath}/age_biyu";
      age_raphael.sopsFile = "${config.homeSpec.secretsPath}/age_raphael";
    };
    templates."keys.txt" = {
      content = ''
        ${config.sops.placeholder.age_yubi}
        ${config.sops.placeholder.age_biyu}
        ${config.sops.placeholder.age_raphael}
      '';
      path = ".config/sops/age/keys.txt";
    };
  };
}
