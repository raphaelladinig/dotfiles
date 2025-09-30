{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  dotnet =
    (
      with pkgs.dotnetCorePackages;
        combinePackages [
          sdk_9_0
          sdk_8_0
        ]
    )
    .overrideAttrs
    (
      finalAttrs: previousAttrs: {
        # NOTE This is needed to install workloads in $HOME

        postBuild =
          (previousAttrs.postBuild or '''')
          + ''
             for i in $out/sdk/*
             do
               i=$(basename $i)
               length=$(printf "%s" "$i" | wc -c)
               substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
               i="$substring""00"
               mkdir -p $out/metadata/workloads/''${i/-*}
               touch $out/metadata/workloads/''${i/-*}/userlocal
            done
          '';
      }
    );
in
  lib.mkIf config.homeSpec.school {
    home.packages = with pkgs; [
      dotnet
      dotnet-ef
      jetbrains.idea-ultimate
      inputs.tapyre.packages.${pkgs.system}.tapyre-astal
    ];

    home.sessionVariables = {
      DOTNET_ROOT = dotnet;
    };
  }
