return {
	settings = {
		nixd = {
			nixpkgs = {
				expr = [[
          let
            flake = builtins.getFlake (toString ./.);
          in
          import flake.inputs.nixpkgs-unstable {
            system = builtins.currentSystem;
            config.allowUnfree = true;
          }
        ]],
			},
			options = {
				darwin = {
					expr = "(builtins.getFlake(toString ./.)).darwinConfigurations.caelum.options",
				},
				home_manager = {
					expr = [[
            (builtins.getFlake(toString ./.)).darwinConfigurations.caelum.options.home-manager.users.type.getSubOptions []
          ]],
				},
			},
		},
	},
}
