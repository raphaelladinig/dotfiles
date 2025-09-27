{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    secrets.url = "git+ssh://git@github.com/raphaelladinig/secrets.git?ref=main&shallow=1";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tapyre = {
      url = "github:tapyre/tapyre";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
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

    nixosModules = builtins.listToAttrs (
      map (module: {
        name = module;
        value = import ./modules/nixos/${module};
      }) (builtins.attrNames (builtins.readDir ./modules/nixos))
    );

    homeManagerModules = builtins.listToAttrs (
      map (module: {
        name = module;
        value = import ./modules/home-manager/${module};
      }) (builtins.attrNames (builtins.readDir ./modules/home-manager))
    );

    nixosConfigurations = builtins.listToAttrs (
      map (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./hosts/${host}
          ];
        };
      }) (builtins.filter (host: host != "common") (builtins.attrNames (builtins.readDir ./hosts)))
    );

    templates = builtins.listToAttrs (
      map (template: {
        name = template;
        value = {
          description = "";
          path = ./templates/${template};
        };
      }) (builtins.attrNames (builtins.readDir ./templates))
    );
  };
}
