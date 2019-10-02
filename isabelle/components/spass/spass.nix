{ stdenv, fetchurl, bison, flex }:

let
  extraTools = stdenv.lib.concatStringsSep " " [
    "FLOTTER" "prolog2dfg" "dfg2otter" "dfg2dimacs" "dfg2tptp"
    "dfg2ascii" "dfg2dfg" "tptp2dfg" "dimacs2dfg" "pgen" "rescmp"
  ];
in

stdenv.mkDerivation rec {
  pname = "spass";
  version = "3.8ds";

  src = fetchurl {
    url = "https://www.cs.vu.nl/~jbe248/${pname}-${version}-src.tar.gz";
    sha256 = "0bzy7mvyvb7xhw7l4z7mysb3p6gmsz9z42ar1rkvvsw4pbfr5gfv";
  };

  nativeBuildInputs = [ bison flex ];

  installPhase = ''
    install -Dt $out/bin SPASS
  '';

}
