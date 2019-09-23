{ stdenv, fetchFromGitHub, ocamlPackages, opaline }:

stdenv.mkDerivation rec {
  pname = "tip-parser";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = pname;
    rev = version;
    sha256 = "1ncqfz2pkg5mxbpwzphqxw0sc7h5rmxyyhmq2acsk1nzv1ydsbmn";
  };

  nativeBuildInputs = with ocamlPackages; [
    ocaml ocamlbuild findlib dune opaline
  ];

  buildInputs = with ocamlPackages; [
    menhir result
  ];

  preInstall = ''
    mkdir -p $out/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib
  '';

}
