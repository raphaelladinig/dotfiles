{ self, lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      host = self.darwinConfigurations.caelum;
      home = host.config.home-manager.users.raphaelladinig;
      neovimHome = pkgs.linkFarm "neovim-check-home" (
        lib.mapAttrsToList
          (_: file: {
            name = file.target;
            path = file.source;
          })
          (
            lib.filterAttrs (
              _: file:
              file.enable
              && (lib.hasPrefix ".config/nvim/" file.target || lib.hasPrefix ".local/share/nvim/" file.target)
            ) home.home.file
          )
      );
      smokeTools = builtins.filter (
        package:
        builtins.elem (lib.getName package) [
          "black"
          "git"
          "lua-language-server"
          "luacheck"
          "nixd"
          "nixfmt"
          "pyright"
          "stylua"
        ]
      ) home.home.packages;
    in
    {
      formatter = pkgs.nixfmt;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          fish
          git
          just
          luajitPackages.luacheck
          nh
          nodejs
          (python3.withPackages (ps: [ ps.plyvel ]))
          stylua
        ];
      };

      packages = lib.optionalAttrs (system == host.pkgs.stdenv.hostPlatform.system) {
        check-neovim = pkgs.writeShellApplication {
          name = "check-neovim";
          inheritPath = false;
          runtimeInputs = [
            home.programs.neovim.finalPackage
            pkgs.python3
          ]
          ++ smokeTools;
          text = ''
            exec python3 -B ${../tests}/neovim_smoke.py "''${1:-${neovimHome}}"
          '';
        };
      };
    };
}
