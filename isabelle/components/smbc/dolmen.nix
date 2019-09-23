{ stdenv, fetchFromGitHub, ocamlPackages, opaline }:

stdenv.mkDerivation rec {
  pname = "dolmen";
  version = "0.4";
  src = fetchFromGitHub {
    owner = "Gbury";
    repo = pname;
    rev = "a5fa52cedf7631087375e9813a8beb8230075c41";
    sha256 = "13lf6lhs3ag5wlzyvq9bcwss1g9hi3v9mgy80ri2lr3z1c0s23cf";
  };

  nativeBuildInputs = with ocamlPackages; [ ocaml findlib ocamlbuild dune opaline ];
  propagatedBuildInputs = with ocamlPackages; [ menhir ];

  installPhase = ''
    opaline -bindir $out/bin -sharedir $out/share -libdir $out/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib
  '';
}
