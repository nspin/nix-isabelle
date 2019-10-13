{ mkComponent, ocamlPackages }:

let
  inherit (ocamlPackages) nunchaku;

in

assert nunchaku.version == "0.5";

mkComponent {
  inherit (nunchaku) name;
  settings = ''
    NUNCHAKU_HOME=${nunchaku}/bin
    NUNCHAKU_VERSION=0.5
  '';
}
