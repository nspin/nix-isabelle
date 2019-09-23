{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "kodkodi";
  version = "1.5.2";

  src = fetchurl {
    url = http://people.mpi-inf.mpg.de/~jblanche/kodkodi-1.5.2.tgz;
    sha256 = "1dx2r8lm8mxz3ba9nfz18kbi8br0nh41bzr32rwpraj86xgxf60m";
  };

  installPhase = ''
    mkdir -p $out/share/jar
    cp jar/* $out/share/jar
  '';
}
