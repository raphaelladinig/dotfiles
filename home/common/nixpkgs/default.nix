# HACK: to fix nix-shell command
{
  home.file = {
    ".config/nixpkgs".source = ./nixpkgs;
  };
}
