{ stdenv, isabelle-src }:

stdenv.mkDerivation {
  pname = "bash_process";
  version = "1.2.3";
  src = isabelle-src;

  phases = [ "unpackPhase" "buildPhase" ];

  buildPhase = ''
    cd Admin/bash_process
    $CC -Wall bash_process.c -o $out
  '';
}
