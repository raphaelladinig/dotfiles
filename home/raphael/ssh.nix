{hostSpec, ...}: let
  secretsPath = hostSpec.secretsPath;
in {
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "github.com" = {
        user = "git";
        hostname = "github.com";
        identityFile = [
          "/home/raphael/.ssh/id_raphael"
        ];
      };
      "128.140.96.126" = {
        user = "root";
        identityFile = [
          "/home/raphael/.ssh/id_raphael"
        ];
      };
    };
  };

  home.file = {
    ".ssh/id_raphael.pub".source = ../../hosts/common/ssh/id_raphael.pub;
    ".ssh/id_yubi.pub".source = ../../hosts/common/ssh/id_yubi.pub;
  };

  age.secrets = {
    id_raphael = {
      file = "${secretsPath}/id_raphael.age";
      path = ".ssh/id_raphael";
    };
    id_yubi = {
      file = "${secretsPath}/id_yubi.age";
      path = ".ssh/id_yubi";
    };
  };
}
