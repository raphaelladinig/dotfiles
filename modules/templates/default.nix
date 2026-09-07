{ ... }:
{
  flake.templates.nix-base = {
    path = ./_nix-base;
    description = "General Nix flake base with Den, flake-parts, and import-tree";
  };
}
