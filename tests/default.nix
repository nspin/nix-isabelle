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

  preferences = writeText "preferences" ''
    ML_system_64 = true
    smt_timeout = 600
  '';
    # timeout = 1048576
    # timeout_scale = 1048576.0

  mk_simple_test = name: cmd: runCommandCC "isabelle-test-${name}" {
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
    ln -s ${preferences} $isabelle_home_user/etc/preferences

    ${cmd}

    touch $out
  '';

  build = "isabelle build"; # -v -j $NIX_BUILD_CORES

in {

  inherit mk_simple_test afp_src;

  lib = mk_simple_test "lib" ''
    ${build} -a
  '';

  libs = sessions: mk_simple_test "libs" ''
    ${build} ${lib.concatStringsSep " " sessions}
  '';

  libx = sessions: mk_simple_test "libx" ''
    ${build} -a ${lib.concatMapStringsSep " " (x: "-x ${x}") sessions}
  '';

  afp = mk_simple_test "afp" ''
    ${build} -d ${afp_src}/thys -g AFP
  '';

  afps = sessions: mk_simple_test "afps" ''
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
        ln -s ${preferences} $isabelle_home_user/etc/preferences
      }
    '';
      # clean() {
      # }
      # isabelle ghc_setup
      # isabelle ocaml_setup
  };

}
