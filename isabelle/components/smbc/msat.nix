{ stdenv, fetchFromGitHub, ocamlPackages, dolmen_0_4 }:

stdenv.mkDerivation rec {
  pname = "msat";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "Gbury";
    repo = "mSAT";
    rev = "v${version}";
    sha256 = "1d3nf7l8s0biwfilyzp323hys1p7xr5yvaqcrg106228rksxz493";
  };

  postPatch = ''
    patchShebangs ./tests
  '';

  nativeBuildInputs = with ocamlPackages; [
    ocaml ocamlbuild findlib 
  ];

  buildInputs = with ocamlPackages; [
    dolmen_0_4
  ];

  preInstall = ''
    mkdir -p $out/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib
  '';

}
