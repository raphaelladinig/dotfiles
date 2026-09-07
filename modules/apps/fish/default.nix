{ ... }:
{
  den.aspects.apps.fish = {
    darwin =
      {
        pkgs,
        user,
        ...
      }:
      {
        environment.shells = [ pkgs.fish ];
        programs.fish.enable = true;
        users.users.${user.userName}.shell = pkgs.fish;
      };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        home.file."${config.xdg.configHome}/fish/config.fish".source = ./config/config.fish;

        xdg.configFile."fish/conf.d/app-aliases.fish".text =
          lib.optionalString (lib.any (package: lib.getName package == "just") config.home.packages) ''
            alias j just
          ''
          + lib.optionalString config.programs.neovim.enable ''
            alias v nvim
          ''
          + lib.optionalString config.programs.lazygit.enable ''
            alias g lazygit
          '';

        xdg.configFile."fish/conf.d/hm-session-vars.fish".source =
          pkgs.runCommandLocal "hm-session-vars.fish" { }
            ''
              {
                echo "function setup_hm_session_vars"
                ${pkgs.buildPackages.babelfish}/bin/babelfish \
                  < ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh
                echo "end"
                echo "setup_hm_session_vars"
              } > "$out"
            '';

        home.packages = with pkgs; [
          direnv
          eza
          fish
          zoxide
        ];
      };
  };
}
