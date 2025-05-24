{
  username,
  userSpec,
  hostSpec,
  config,
  outputs,
  ...
}: {
  imports = [
    outputs.homeManagerModules.home-spec
    ../../../home/${username}
  ];

  homeSpec =
    {
      stateVersion = hostSpec.stateVersion;
    }
    // userSpec;

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = config.homeSpec.stateVersion;
  };
}
