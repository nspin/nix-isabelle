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

in rec {
  inherit pkgs;
  inherit (pkgs) isabelle;
  inherit (isabelle) components tests;
}
