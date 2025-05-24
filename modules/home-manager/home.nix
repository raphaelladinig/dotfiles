{
  username,
  userSpec,
  hostSpec,
  config,
  ...
}: {
  imports = [
    ../../home/${username}
    ./home-spec.nix
  ];

  homeSpec =
    {
      stateVersion = hostSpec.stateVersion;
    }
    // userSpec.${username};

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = config.homeSpec.stateVersion;
  };
}
