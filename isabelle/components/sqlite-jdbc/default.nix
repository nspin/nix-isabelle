{ mkComponent, hostPlatform, runCommand, callPackage }:

let
  sqlite-jdbc = callPackage ./sqlite-jdbc.nix {};

  home = runCommand "sqlite-home" {} ''
    mkdir -p $out/${hostPlatform.system}
    ln -s ${sqlite-jdbc}/lib/libsqlitejdbc.so $out/${hostPlatform.system}
  '';

in
mkComponent {
  inherit (sqlite-jdbc) name;
  settings = ''
    ISABELLE_SQLITE_HOME=${home}
    classpath ${sqlite-jdbc}/share/java/${sqlite-jdbc.name}.jar
  '';
  passthru = {
    inherit sqlite-jdbc home;
  };
}
