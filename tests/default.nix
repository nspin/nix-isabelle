{ stdenv, lib, hostPlatform, runCommandCC, writeText, mkShell, fetchhg
, haskell, ocamlPackages, gmp
, perl, hostname, unzip, gnum4
, darwin, xcbuild
, isabelle
}:

let
  afp_src = stdenv.mkDerivation {
    name = "afp-src";
    src = fetchhg {
      url = https://bitbucket.org/isa-afp/afp-2019;
      rev = "1c0ae055c848bf7ad7bcb8fb6a22fda3568de793";
      sha256 = "0mpg0ks4h666vi65xvrxvq1zx7j3mrffw80r963hp5s1i9vhf9b8";
    };
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    patches = [
      ./patches/afp-export-code.patch
    ];
    installPhase = ''
      mkdir $out
      mv * $out
    '';
  };

  preferences = smt_timeout: writeText "preferences" ''
    ML_system_64 = true
    smt_timeout = ${toString smt_timeout}
  '';
    # TODO timeout and timeout_scale

  mkSimpleTest = name: cmd: runCommandCC "isabelle-test" {
    nativeBuildInputs = [
      isabelle
      perl hostname unzip
      ocamlPackages.ocaml gmp
    ];
  } ''
    export HOME=$NIX_BUILD_TOP/home
    mkdir $HOME

    export OCAMLPATH=${ocamlPackages.zarith}/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib
    export ISABELLE_OCAMLFIND=${ocamlPackages.findlib}/bin/ocamlfind
    # matches ISABELLE_GHC_VERSION=ghc-8.4.4
    export ISABELLE_GHC=${haskell.packages.ghc844.ghc}/bin/ghc

    isabelle_home_user=$(isabelle env bash -c 'echo $ISABELLE_HOME_USER')
    mkdir -p $isabelle_home_user/etc
    ln -s ${preferences 60} $isabelle_home_user/etc/preferences

    ${cmd}

    touch $out
  '';

  build = "isabelle build";

in {

  inherit mkSimpleTest afp_src;

  lib = mkSimpleTest "lib" ''
    ${build} -a
  '';

  libSessions = sessions: mkSimpleTest ''
    ${build} ${lib.concatStringsSep " " sessions}
  '';

  libWithoutSessions = sessions: mkSimpleTest ''
    ${build} -a ${lib.concatMapStringsSep " " (x: "-x ${x}") sessions}
  '';

  afpSessions = sessions: mkSimpleTest ''
    ${build} -d ${afp_src}/thys ${lib.concatStringsSep " " sessions}
  '';

  shell = mkShell {
    nativeBuildInputs = [
      perl hostname unzip gnum4
      isabelle
    ] ++ lib.optionals hostPlatform.isDarwin [
      xcbuild
    ];
    buildInputs = [
     gmp
    ] ++ lib.optionals hostPlatform.isDarwin [
      darwin.libiconv
    ];
    shellHook = ''
      afp=${afp_src}/thys
      setup() {
        isabelle_home_user=$(isabelle env bash -c 'echo $ISABELLE_HOME_USER')
        mkdir -p $isabelle_home_user/etc
        ln -s ${preferences 600} $isabelle_home_user/etc/preferences
      }
      lang_setup() {
        isabelle ghc_setup
        isabelle ocaml_setup
      }
    '';
  };

}
