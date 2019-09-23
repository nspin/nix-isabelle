{ mkComponent, callPackage, ocamlPackages }:

let
  nunchaku = callPackage ./nunchaku.nix rec {
    menhir = ocamlPackages.menhir.override {
      version = "20170712";
    };
  };

in
mkComponent {
  inherit (nunchaku) name;
  settings = ''
    NUNCHAKU_HOME=${nunchaku}/bin
    NUNCHAKU_VERSION=0.5
  '';
  passthru = {
    inherit nunchaku;
  };
}
