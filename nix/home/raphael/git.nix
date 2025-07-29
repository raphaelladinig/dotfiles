{config, ...}: {
  programs.git = {
    enable = true;
    userName = config.homeSpec.name;
    userEmail = config.homeSpec.email;
    extraConfig = {
      pull = {
        rebase = false;
      };
      user.signingkey = "/home/raphael/.ssh/ssh_raphael.pub";
    };
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    lfs.enable = true;
  };
}
