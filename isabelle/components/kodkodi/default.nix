{ mkComponent, lib, callPackage, writeScriptBin, runtimeShell
, gccStdenv
}:

let
  kodkod = callPackage ./kodkod.nix {
    stdenv = gccStdenv;
  };

  kodkodi = callPackage ./kodkodi.nix {};

  # TODO is all this necessary?
  bin = writeScriptBin "kodkodi" ''
    #!${runtimeShell}
    export CLASSPATH="$KODKODI_CLASSPATH:$CLASSPATH"
    export JAVA_LIBRARY_PATH="$KODKODI_JAVA_LIBRARY_PATH:$JAVA_LIBRARY_PATH"

    case "$ML_PLATFORM" in
      *-linux)
        export LD_LIBRARY_PATH="$KODKODI_JAVA_LIBRARY_PATH:$LD_LIBRARY_PATH"
        ;;
    esac

    exec "$ISABELLE_TOOL" java $KODKODI_JAVA_OPT de.tum.in.isabelle.Kodkodi.Kodkodi "$@"
  '';

in
mkComponent {
  name = "kodkodi-1.5.2";

  settings = ''
    KODKODI=${bin}
    KODKODI_VERSION=1.5.2
    KODKODI_JAVA_OPT=
    KODKODI_CLASSPATH=${lib.concatMapStringsSep ":" (x: "${kodkodi}/share/jar/${x}") [
      "antlr-runtime-3.1.1.jar"
      "kodkod-1.5.jar"
      "kodkodi-1.5.2.jar"
      "sat4j-2.3.jar"
    ]}
    KODKODI_JAVA_LIBRARY_PATH=${kodkod}/share/jni
  '';

  passthru = {
    inherit kodkod kodkodi bin;
  };

}
