{ ... }:
{
  den.aspects.fonts.darwin =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        nerd-fonts.caskaydia-cove
        nerd-fonts.symbols-only
      ];
    };
}
