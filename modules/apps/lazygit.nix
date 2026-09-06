{ ... }:
{
  den.aspects.apps.lazygit.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.delta ];

      programs.lazygit = {
        enable = true;

        settings.git = {
          diffRenderers = [
            {
              type = "stdinFilter";
              command = "delta --paging=never --syntax-theme none --minus-style red --minus-emph-style 'reverse red' --plus-style green --plus-emph-style 'reverse green'";
              colorArg = "always";
            }
          ];

          overrideGpg = true;
        };
      };
    };
}
