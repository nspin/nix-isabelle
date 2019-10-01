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

   pass = assert pkgs.hostPlatform.isx86_64; tests.libx [
     "HOL-Metis_Examples"
   ];

}
