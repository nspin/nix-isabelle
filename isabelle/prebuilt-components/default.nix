{ lib, mkPrebuiltComponent }:

lib.mapAttrs (n: v: lib.mapAttrs mkPrebuiltComponent v) (import ./hashes.nix)
