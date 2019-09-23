{ mkComponent, callPackage, runCommand }:

let
  cvc4 = callPackage ./cvc4.nix {
    inherit libantlr3c;
  };
  libantlr3c = callPackage ./libantlr.nix {};

  home = runCommand "cvc4-home" {} ''
    mkdir $out
    ln -s ${cvc4}/bin/* $out
    ln -s ${cvc4}/lib/* $out
  '';

in
mkComponent {
  inherit (cvc4) name;
  settings = ''
    CVC4_HOME=${home}
    CVC4_VERSION=1.5
    CVC4_SOLVER=${cvc4}/bin/cvc4
    CVC4_INSTALLED=yes
  '';
  passthru = {
    inherit cvc4;
  };
}
