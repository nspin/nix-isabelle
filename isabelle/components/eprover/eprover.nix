{ stdenv, fetchurl, which }:

stdenv.mkDerivation rec {
  pname = "e";
  version = "2.0";

  src = fetchurl {
    url = "https://wwwlehre.dhbw-stuttgart.de/~sschulz/WORK/E_DOWNLOAD/V_${version}/E.tgz";
    sha256 = "1xmwr32pd8lv3f6yh720mdqhi3na505y3zbgcsgh2hwb7b5i3ngb";
  };

  buildInputs = [ which ];

  preConfigure = ''
    sed -e '/CC = gcc/d' -i Makefile.vars
  '';

  configureFlags = [
    "--exec-prefix=$(out)"
    "--man-prefix=$(out)/share/man"
  ];
}
