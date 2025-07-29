{inputs, ...}: {
  additions = final: prev:
    import ../packages {pkgs = final;};

  modifications = final: prev: {
    nnn = import ./nnn.nix {inherit prev;};
  };

  nixpkgs-stable = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  nixpkgs-unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
