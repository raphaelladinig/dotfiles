{ ... }:
{
  perSystem =
    { pkgs, ... }:
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
          stylua
        ];
      };
    };
}
