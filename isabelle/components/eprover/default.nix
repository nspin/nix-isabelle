{ mkComponent, callPackage, runCommand }:

let
  eprover = callPackage ./eprover.nix {};

in
mkComponent {
  inherit (eprover) name;
  settings = ''
    E_HOME=${eprover}/bin
    E_VERSION=2.0
  '';
  passthru = {
    inherit eprover;
  };
}
