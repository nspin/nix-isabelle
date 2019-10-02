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
