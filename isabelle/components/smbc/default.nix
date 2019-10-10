{ mkComponent, callPackage }:

let
  smbc = callPackage ./smbc.nix {
    inherit msat tip-parser sequence;
  };

  dolmen_0_4 = callPackage ./dolmen.nix {};
  msat = callPackage ./msat.nix {
    inherit dolmen_0_4;
  };
  tip-parser = callPackage ./tip-parser.nix {};
  ocamlPackages = callPackage ({ ocamlPackages }: ocamlPackages) {};
  sequence = callPackage ./sequence.nix {
    inherit (ocamlPackages) buildDunePackage qtest result;
  };

in
mkComponent {
  inherit (smbc) name;
  settings = ''
    SMBC_HOME=${smbc}/bin
    SMBC_VERSION=${smbc.version}
  '';
  passthru = {
    inherit smbc msat dolmen_0_4 tip-parser;
  };
}
