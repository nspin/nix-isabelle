{ stdenv, lib, hostPlatform, fetchFromGitHub, python2 }:

stdenv.mkDerivation rec {
  pname = "z3";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner  = "Z3Prover";
    repo   = "z3";
    rev    = "z3-${version}";
    sha256 = "1xllvq9fcj4cz34biq2a9dn2sj33bdgrzyzkj26hqw70wkzv1kzx";
  };

  postPatch = lib.optionalString hostPlatform.isAarch64 ''
    substituteInPlace scripts/mk_util.py --replace '-mfpmath=sse' ""
    substituteInPlace scripts/mk_util.py --replace '-msse2' ""
    substituteInPlace scripts/mk_util.py --replace '-msse' ""

    substituteInPlace src/util/hwf.cpp --replace 'include <emmintrin.h>' 'undef USE_INTRINSICS'
  '';

  nativeBuildInputs = [ python2 ];

  enableParallelBuilding = true;

  CXXFLAGS = [ "-std=c++03" ];

  configurePhase = ''
    python scripts/mk_make.py --prefix=$out
    cd build
  '';

  installPhase = ''
    install -D -t $out/bin z3
    install -D -t $out/lib libz3.*
  '';
}
