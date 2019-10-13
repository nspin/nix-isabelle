{ mkComponent, stdenv, lib, callPackage, runCommand, hostPlatform, polyml }:

let
  polyml_ = polyml;
in
let
  polyml = lib.overrideDerivation polyml_ (attrs: {
    configureFlags = attrs.configureFlags ++ [ "--enable-intinf-as-int" ];
  });

  sha1 = callPackage ./sha1.nix {};

  ml_home = runCommand "ml-home" {} ''
    mkdir $out
    ln -s ${polyml}/bin/* $out
    ln -s ${polyml}/lib/* $out
    ln -s ${sha1}/lib/* $out
  '';

  source = stdenv.mkDerivation {
    name = "${polyml.name}-source";
    inherit (polyml) src;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir $out
      mv * $out
    '';
  };

  polyml_home = runCommand "polyml-home" {} ''
    mkdir $out
    touch $out/README
  '';

in
mkComponent {
  inherit (polyml) name;
  settings = ''
    POLYML_HOME=${polyml_home}
    ML_PLATFORM=${hostPlatform.config}
    ML_SYSTEM=${polyml.name}
    ML_SYSTEM_64=true
    ML_HOME=${ml_home}
    ML_SOURCES=${source}
    ML_OPTIONS="--minheap 1000"
  '';
  passthru = {
    inherit polyml sha1;
  };
}
