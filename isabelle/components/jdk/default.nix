{ mkComponent, callPackage, jdk11, hostPlatform }:

let
  openjdk11-binary = callPackage ./openjdk-11-binary-zulu.nix {};

  openjdk11 = callPackage ./openjdk-11.nix {
    bootjdk = openjdk11-binary;
  };

  jdk = if hostPlatform.isAarch64 then openjdk11 else jdk11;

in
mkComponent {
  inherit (jdk) name;
  settings = ''
    ISABELLE_JAVA_PLATFORM=${hostPlatform.config}
    ISABELLE_JDK_HOME=${jdk}
  '';
  passthru = {
    inherit openjdk11 openjdk11-binary;
  };
}
