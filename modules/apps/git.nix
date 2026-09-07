{ ... }:
let
  email = "mail@raphaelladinig.com";
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINksZNshClOrKz5K4mQTrRHrsezJmaJcFGe/ptPgKEP1";
in
{
  den.aspects.apps.git.homeManager.programs.git = {
    enable = true;
    settings.user.email = email;
    signing = {
      format = "ssh";
      # KeePassXC provides the matching private key through ssh-agent.
      key = "key::${signingKey}";
      signByDefault = true;
      allowedSigners = ''
        ${email} namespaces="git" ${signingKey}
      '';
    };
    ignores = [ ".DS_Store" ];
  };
}
