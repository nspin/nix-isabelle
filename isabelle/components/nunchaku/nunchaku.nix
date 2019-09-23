{ stdenv, buildPlatform, fetchgit, ocamlPackages
, menhir
}:

stdenv.mkDerivation rec {
  pname = "nunchaku";
  version = "0.5";

  src = fetchgit {
    url = "https://github.com/nunchaku-inria/${pname}";
    rev = version;
    # TODO ?
    sha256 = if buildPlatform.isLinux
      then "184varmjhffv647zlgh9wa5zm7cqqrz45g2kp0khslsyjh7fvixx"
      else "1np88k0shpqc5amvqndni4xcfn620dh784yipr9l42fvb8c3dhkp";
    # sha256 = if buildPlatform.isAarch64
    #   then "184varmjhffv647zlgh9wa5zm7cqqrz45g2kp0khslsyjh7fvixx"
    #   else "1np88k0shpqc5amvqndni4xcfn620dh784yipr9l42fvb8c3dhkp";
  };

  patches = [
    ./newer-ocaml.patch
  ];

  nativeBuildInputs = with ocamlPackages; [
    ocaml ocamlbuild findlib
  ];

  buildInputs = [ menhir ] ++ (with ocamlPackages; [
    containers sequence num qcheck ounit
  ]);

  preInstall = "
    mkdir -p $out/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib
  ";
}
