{ stdenv, lib, hostPlatform, fetchurl }:

stdenv.mkDerivation rec {
  name = "libantlr3c-3.4";
  src = fetchurl {
    url = "https://www.antlr3.org/download/C/${name}.tar.gz";
    sha256 ="0lpbnb4dq4azmsvlhp6khq1gy42kyqyjv8gww74g5lm2y6blm4fa";
  };

  configureFlags = lib.optionals hostPlatform.is64bit [
    "--enable-64bit"
  ] ++ lib.optionals (with hostPlatform; isArm || isAarch64) [
    "--disable-abiflags"
  ];
}
