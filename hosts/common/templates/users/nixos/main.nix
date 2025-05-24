{
  config,
  username,
  ...
} @ args: {
  imports = [
    (import ../../../home-manager.nix (args // {inherit username;}))
    ../../../agenix.nix
  ];

  userSpec.${username} = {
    homeManager = true;
    agenixIdentityPaths = config.hostSpec.agenixIdentityPaths;
  };

  age.secrets."password_${username}".file = "${config.hostSpec.secretsPath}/password_${username}.age";

  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."password_${username}".path;
    extraGroups = config.userSpec.${username}.extraGroups;
  };
}
