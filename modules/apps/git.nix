{ ... }:
{
  den.aspects.apps.git.homeManager.programs.git = {
    enable = true;
    settings.user.email = "mail@raphaelladinig.com";
    ignores = [ ".DS_Store" ];
  };
}
