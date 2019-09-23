{ stdenv, fetchurl, cln, gmp, swig, pkgconfig
, readline, libantlr3c, boost, autoreconfHook
, python2, antlr3_4
}:

stdenv.mkDerivation rec {
  name = "cvc4-1.5";

  src = fetchurl {
    url = "https://cvc4.cs.stanford.edu/downloads/builds/src/${name}.tar.gz";
    sha256 = "0yxxawgc9vd2cz883swjlm76rbdkj48n7a8dfppsami530y2rvhi";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ gmp cln readline swig libantlr3c antlr3_4 boost python2 ];
  configureFlags = [
    "--enable-gpl"
    "--with-cln"
    "--with-readline"
    "--with-boost=${boost.dev}"
  ];

  preConfigure = ''
    patchShebangs src
  '';

  enableParallelBuilding = true;
}
