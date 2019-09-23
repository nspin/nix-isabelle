{ stdenv, fetchFromGitHub
, wafHook, jdk, zlib
}:

stdenv.mkDerivation rec {
  pname = "kodkod";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner  = "msakai";
    repo   = "kodkod";
    rev    = version;
    sha256 = "1iaw95q6ylz7g847jpz92bgd0z9is3lzkkc2b7q1rcc3yhp8m22m";
  };

  nativeBuildInputs = [ wafHook jdk ];
  buildInputs = [ zlib ];

  postPatch = ''
    substituteInPlace wscript --replace bld.variant True
  '';

  postInstall =
    let
      dir = with stdenv.hostPlatform.parsed; "${kernel.name}_${cpu.name}";
    in ''
      mkdir -p $out/bin $out/share/jni
      mv ${dir}/*.* $out/share/jni
      mv ${dir}/* $out/bin
    '';

}
