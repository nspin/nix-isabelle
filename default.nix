let
  pkgs = import ./nixpkgs {
    overlays = [
      (import ./isabelle/overlay.nix)
    ];
    config = {
      allowUnfree = true;
      oraclejdk.accept_license = true;
    };
  };

  tests = pkgs.callPackage ./tests {};

in rec {

  inherit pkgs;
  inherit (pkgs) isabelle;
  inherit (isabelle) components prebuiltComponents;
  inherit tests;

}

# NOTE
# tests.lib skips the 'Haskell' session, which uses stack.
# Building this session works find outside of the sandbox, after running 'isabelle ghc_setup'
