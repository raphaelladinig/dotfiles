{lib, ...}: {
  options.homeSpec = lib.mkOption {
    type = lib.types.attrs;
  };
}
