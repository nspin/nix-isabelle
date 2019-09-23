{ mkComponent, stdenv, lib, callPackage, runCommand, hostPlatform }:

with lib;

let
  polyml = callPackage ./polyml.nix {};
  sha1 = callPackage ./sha1.nix {};

  home = runCommand "ml-home" {} ''
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

in
mkComponent {
  inherit (polyml) name;
  settings = ''
    ML_PLATFORM=${hostPlatform.config}
    ML_SYSTEM=${polyml.name}
    ML_HOME=${home}
    ML_SOURCES=${source}
    ML_OPTIONS="--minheap 1000"
  '';
  passthru = {
    inherit polyml sha1;
  };
}
