{ mkComponent, callPackage, ocamlPackages }:

let
  nunchaku = callPackage ./nunchaku.nix rec {
    menhir = ocamlPackages.menhir.override {
      version = "20170712";
    };
    inherit sequence;
  };

  ocamlPackages = callPackage ({ ocamlPackages }: ocamlPackages) {};
  sequence = callPackage ../smbc/sequence.nix {
    inherit (ocamlPackages) buildDunePackage qtest result;
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
