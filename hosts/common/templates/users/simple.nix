{
  config,
  username,
  outputs,
  ...
} @ args: {
  imports = [
    (outputs.nixosModules.user-spec (args // {inherit username;}))
    (import ../../home-manager.nix (args // {inherit username;}))
  ];

  "userSpec-${username}".homeManager = true;

  sops.secrets."password_${username}" = {
    sopsFile = "${config.hostSpec.secretsPath}/password_${username}";
    neededForUsers = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."password_${username}".path;
    extraGroups = config."userSpec-${username}".extraGroups;
  };
}
