{lib, ...}: {
  options =
    {
      userSpec = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };
    }
    // builtins.listToAttrs (
      map (username: {
        name = "userSpec.${username}";
        value = lib.mkOption {
          type = lib.types.attrs;
        };
      }) (builtins.attrNames (builtins.readDir ../../hosts/common/users/nixos))
    );
}
