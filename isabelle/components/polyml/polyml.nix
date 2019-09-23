{ stdenv, lib, fetchFromGitHub, autoreconfHook, gmp, libffi }:

stdenv.mkDerivation rec {
  pname = "polyml";
  version = "5.8";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "1s7q77bivppxa4vd7gxjj5dbh66qnirfxnkzh1ql69rfx1c057n3";
  };

  buildInputs = [ libffi gmp ];

  configureFlags = [
    "--disable-shared"
    "--enable-intinf-as-int"
    "--with-system-libffi"
    "--with-gmp"
  ];
}
