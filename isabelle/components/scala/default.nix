{ mkComponent, callPackage }:

let
  scala = callPackage ./scala.nix {};

in
mkComponent {
  inherit (scala) name;
  settings = ''
    SCALA_HOME=${scala}
    classpath ${scala}/lib/jline-2.14.6.jar
    classpath ${scala}/lib/scala-compiler.jar
    classpath ${scala}/lib/scala-library.jar
    classpath ${scala}/lib/scalap-2.12.7.jar
    classpath ${scala}/lib/scala-parser-combinators_2.12-1.0.7.jar
    classpath ${scala}/lib/scala-reflect.jar
    classpath ${scala}/lib/scala-swing_2.12-2.0.3.jar
    classpath ${scala}/lib/scala-xml_2.12-1.0.6.jar
  '';
  passthru = {
    inherit scala;
  };
}
