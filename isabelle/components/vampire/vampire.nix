{ stdenv, fetchFromGitHub, fetchpatch, z3, zlib, git }:

stdenv.mkDerivation rec {
  pname = "vampire";
  version = "4.2.2";

  src = fetchFromGitHub {
    owner = "vprover";
    repo = pname;
    rev = version;
    sha256 = "03dqjxr3cwz4h6sn9074kc6b6wjz12kpsvsi0mq2w0j5l9f8d80y";
  };

  patches = [
    (fetchpatch {
      name = "fix-apple-cygwin-defines.patch";
      url = https://github.com/vprover/vampire/pull/54.patch;
      sha256 = "0i6nrc50wlg1dqxq38lkpx4rmfb3lf7s8f95l4jkvqp0nxa20cza";
    })
    (fetchpatch {
      name = "fix-templates.patch";
      url = https://github.com/vprover/vampire/commit/1af60f1cd3241a8baaec828927df7d00a5a32bbf.patch;
      sha256 = "1lqlxfwb68av53xnjc73xaw7k8ypxlqnqc0ybh9r5yrds6jrw2i2";
    })
  ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ git ];
  buildInputs = [ z3 zlib ];

  makeFlags = [ "CC:=$(CC)" "CXX:=$(CXX)" ];
  buildFlags = [ "vampire_z3_rel" ];

  installPhase = ''
    install -m0755 -D vampire_z3_rel* $out/bin/vampire
  '';
}
