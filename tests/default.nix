{ runCommand, lib, fetchhg
, perl, hostname, unzip
, isabelle
}:

let
  afp_src = fetchhg {
    url = https://bitbucket.org/isa-afp/afp-2019;
    rev = "1c0ae055c848bf7ad7bcb8fb6a22fda3568de793";
    sha256 = "0mpg0ks4h666vi65xvrxvq1zx7j3mrffw80r963hp5s1i9vhf9b8";
  };

  mk_simple_test = name: cmd: runCommand "isabelle-test-${name}" {
    nativeBuildInputs = [
      isabelle
      perl hostname unzip
    ];
  } ''
    export HOME=$NIX_BUILD_TOP/home
    mkdir $HOME

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

}
