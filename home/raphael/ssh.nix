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
          "/home/raphael/.ssh/ssh_raphael"
        ];
      };
      "5.75.151.162" = {
        user = "root";
        identityFile = [
          "/home/raphael/.ssh/ssh_raphael"
        ];
      };
    };
  };

  home.file = {
    ".ssh/ssh_raphael.pub".source = ../../hosts/common/ssh/ssh_raphael.pub;
    ".ssh/ssh_yubi.pub".source = ../../hosts/common/ssh/ssh_yubi.pub;
  };

  sops.secrets = {
    ssh_raphael = {
      sopsFile = "${secretsPath}/ssh_raphael";
      path = ".ssh/ssh_raphael";
    };
    ssh_yubi = {
      sopsFile = "${secretsPath}/ssh_yubi";
      path = ".ssh/ssh_yubi";
    };
  };
}
