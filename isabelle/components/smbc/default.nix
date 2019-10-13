{ mkComponent, ocamlPackages }:

let
  inherit (ocamlPackages) smbc;

in

assert smbc.version == "0.4.1";

mkComponent {
  inherit (smbc) name;
  settings = ''
    SMBC_HOME=${smbc}/bin
    SMBC_VERSION=${smbc.version}
  '';
}
