{ stdenv, lib, fetchhg }:

stdenv.mkDerivation {
  name = "isabelle-sha1";

  src = fetchhg {
    url = "https://isabelle.sketis.net/repos/sha1";
    rev = "64caa3aa1053";
    sha256 = "0ml568ildjn7nr8vwn177wrhzh5pbyxmwrlsvjzm0wnznl2b2lmz";
  };

  buildPhase = (if stdenv.isDarwin then ''
    LDFLAGS="-dynamic -undefined dynamic_lookup -lSystem"
  '' else ''
    LDFLAGS="-fPIC -shared"
  '') + ''
    CFLAGS="-fPIC -I."
    $CC $CFLAGS -c sha1.c -o sha1.o
    $LD $LDFLAGS sha1.o -o libsha1.so
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp libsha1.so $out/lib/libsha1.so
  '';

}
