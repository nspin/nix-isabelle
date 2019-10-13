{ mkComponent, callPackage, vampire }:

assert vampire.version == "4.4";

mkComponent {
  inherit (vampire) name;
  settings = ''
    VAMPIRE_HOME=${vampire}/bin
    VAMPIRE_VERSION=${vampire.version}
    VAMPIRE_EXTRA_OPTIONS="--mode casc"
  '';
}
