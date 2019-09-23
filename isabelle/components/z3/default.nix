{ mkComponent, callPackage }:

let
  z3 = callPackage ./z3.nix {};

in
mkComponent {
  inherit (z3) name;
  settings = ''
    Z3_HOME=${z3}
    Z3_VERSION=${z3.version}
    Z3_SOLVER=${z3}/bin/z3
    Z3_INSTALLED=yes
  '';
  passthru = {
    inherit z3;
  };
}
