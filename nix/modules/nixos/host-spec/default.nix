{lib, ...}: {
  options.hostSpec = lib.mkOption {
    type = lib.types.attrs;
  };
}
