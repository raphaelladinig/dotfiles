{ den, ... }:
{
  den.hosts.aarch64-darwin.caelum = {
    aspect = den.aspects.hosts.caelum;
    users.raphaelladinig.aspect = den.aspects.users.raphaelladinig;
  };
}
