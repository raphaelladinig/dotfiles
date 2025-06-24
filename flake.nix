{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    secrets.url = "git+ssh://git@github.com/raphaelladinig/secrets.git?ref=main&shallow=1";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;

    systems = [
      "x86_64-linux"
    ];

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f pkgsFor.${system});

    pkgsFor = nixpkgs.lib.genAttrs systems (
      system:
        import nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays;
          config.allowUnfree = true;
        }
    );
  in {
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    devShells = forAllSystems (
      pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            git
            just
            age
            ssh-to-age
            nixos-anywhere
            disko
            cryptsetup
            yubikey-manager
          ];
        };
      }
    );

    packages = forAllSystems (pkgs: import ./packages {inherit pkgs;});

    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations = builtins.listToAttrs (
      map (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./hosts/nixos/${host}
            ./modules/nixos/host-spec.nix
            ./modules/nixos/user-spec.nix
          ];
        };
      }) (builtins.attrNames (builtins.readDir ./hosts/nixos))
    );

    templates = {
      simple = {
        description = "simple flake template";
        path = ./templates/simple;
      };

      default = self.templates.simple;
    };
  };
}
