default:
  @just --list

rebuild mode="switch" host="${HOSTNAME}":
  sudo nixos-rebuild {{mode}} --flake .#{{host}}

rebuild-boot host="${HOSTNAME}": (rebuild "boot" host)

format-disk arg:
  #!/bin/sh
  file={{arg}}

  if [ -f "./hosts/nixos/{{arg}}/disk-config.nix" ]; then
    file="./hosts/nixos/{{arg}}/disk-config.nix"
  fi

  sudo disko --mode disko "$file"

install host="${HOSTNAME}":
  sudo nixos-install --no-root-passwd --flake .#{{host}}

update: 
  nix flake update

clean: clean-persist collect-garbage

clean-persist:
  sudo PERSIST_DIRS="$PERSIST_DIRS" PERSIST_FILES="$PERSIST_FILES" ./scripts/clean-persist.sh

collect-garbage:
  sudo nix-collect-garbage -d
