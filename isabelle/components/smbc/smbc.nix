{ stdenv, fetchFromGitHub, ocamlPackages, git
, sequence, msat, tip-parser
}:

stdenv.mkDerivation rec {
  pname = "smbc";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = pname;
    rev = version;
    sha256 = "1bh49j1balqms8yqkchj0l472nbfwnl3bvsy8z9lz928wv9vpx5q";
  };

  patches = [
    ./containers-bump.patch
  ];

  nativeBuildInputs = with ocamlPackages; [
    ocaml ocamlbuild findlib git
  ];

  buildInputs = with ocamlPackages; [
    containers menhir
    sequence msat tip-parser
  ];

  preInstall = "
    mkdir -p $out/bin
  ";

  installFlags = [
    "BINDIR=$(out)/bin"
  ];

}
