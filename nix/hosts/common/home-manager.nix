{
  inputs,
  outputs,
  config,
  lib,
  username,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = lib.mkIf config."userSpec-${username}".homeManager {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs username;
      hostSpec = config.hostSpec;
      userSpec = config."userSpec-${username}";
    };
    users.${username} = outputs.homeManagerModules.home;
  };
}
