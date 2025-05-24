{config, ...}: {
  programs.git = {
    enable = true;
    userName = config.homeSpec.name;
    userEmail = config.homeSpec.email;
    extraConfig = {
      pull = {
        rebase = false;
      };
      user.signingkey = "/home/raphael/.ssh/id_yubi.pub";
    };
    signing.format = "ssh";
    lfs.enable = true;
  };
}
