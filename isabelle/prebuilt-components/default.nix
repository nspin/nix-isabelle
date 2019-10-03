{ lib, mkPrebuiltComponent }:

lib.mapAttrs mkPrebuiltComponent (import ./hashes.nix)
