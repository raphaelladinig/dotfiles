{ inputs, ... }:
let
  nixpkgsConfig = system: {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = final.config.allowUnfree or false;
        };
        unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = final.config.allowUnfree or false;
        };
        # The locked WhatsApp release is no longer available from upstream.
        whatsapp-for-mac = prev.whatsapp-for-mac.overrideAttrs (finalAttrs: {
          version = "2.26.44.15";
          src = prev.fetchzip {
            extension = "zip";
            name = "WhatsApp.app";
            url = "https://web.whatsapp.com/desktop/mac_native/release/?version=${finalAttrs.version}&extension=zip&configuration=Release&branch=master&is_buck=true";
            hash = "sha256-U3Fr5Gg2L6e2Bdu/qWIVYuWQ1xPER9fuTLo39Q6j/4U=";
          };
        });
      })
    ];
  };
in
{
  flake-file.inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs-unstable ({ inherit system; } // nixpkgsConfig system);
    };

  den.aspects.nixpkgs.darwin =
    { system, ... }:
    {
      nixpkgs = nixpkgsConfig system;
    };
}
