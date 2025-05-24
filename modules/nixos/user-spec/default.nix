{
  lib,
  username,
  ...
}: {
  options."userSpec-${username}" = lib.mkOption {
    type = lib.types.attrs;
  };
}
