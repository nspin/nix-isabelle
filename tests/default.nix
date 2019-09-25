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

  mkSimpleTest = name: cmd: runCommand "isabelle-test-${name}" {
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

  build = "isabelle build";
  # build = "isabelle build -v";
  # build = "isabelle build -j $NIX_BUILD_CORES";

in {

  inherit afp_src;

  lib = mkSimpleTest "lib" ''
    ${build} -a
  '';

  libs = sessions: mkSimpleTest "libs" ''
    ${build} ${lib.concatStringsSep " " sessions}
  '';

  libx = sessions: mkSimpleTest "libx" ''
    ${build} -a ${lib.concatMapStringsSep " " (x: "-x ${x}") sessions}
  '';

  afp = mkSimpleTest "afp" ''
    ${build} -d ${afp_src}/thys -g AFP
  '';

  afps = sessions: mkSimpleTest "afps" ''
    ${build} -d ${afp_src}/thys ${lib.concatStringsSep " " sessions}
  '';

}