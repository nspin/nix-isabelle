{ mkComponent, lib, callPackage
, gccStdenv
}:

let
  kodkod = callPackage ./kodkod.nix {
    stdenv = gccStdenv;
  };

  kodkodi = callPackage ./kodkodi.nix {};

  # sat4j = fetchurl {
  #   url = "http://download.forge.ow2.org/sat4j/sat4j-core-v20130525.zip";
  #   sha256 = "1615hh10m19q3pkm21y0v7k42qvc1mza0q03ws4vn0vfhgjfg8p9";
  # };

in
mkComponent {
  name = "kodkodi-1.5.2";

  settings = ''
    KODKODI="$COMPONENT"
    KODKODI_VERSION=1.5.2
    KODKODI_JAVA_OPT=
    KODKODI_CLASSPATH=${lib.concatMapStringsSep ":" (x: "${kodkodi}/share/jar/${x}") [
      "antlr-runtime-3.1.1.jar"
      "kodkod-1.5.jar"
      "kodkodi-1.5.2"
      "sat4j-2.3.jar"
    ]}
    KODKODI_JAVA_LIBRARY_PATH=${kodkod}/share/jni
  '';

  passthru = {
    inherit kodkod kodkodi;
  };

}
