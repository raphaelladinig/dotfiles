{ den, ... }:
{
  den.hosts.aarch64-darwin.sol = {
    aspect = den.aspects.hosts.sol;
    users.raphaelladinig.aspect = den.aspects.users.raphaelladinig;
  };
}
