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

in {

  lib = mkSimpleTest "lib" ''
    isabelle build -j $NIX_BUILD_CORES -a
  '';

  libs = sessions: mkSimpleTest "libs" ''
    isabelle build -j $NIX_BUILD_CORES ${lib.concatStringsSep " " sessions}
  '';

  afp = mkSimpleTest "afp" ''
    isabelle build -j $NIX_BUILD_CORES -d ${afp_src}/thys -g AFP
  '';

  afps = sessions: mkSimpleTest "afps" ''
    isabelle build -j $NIX_BUILD_CORES -d ${afp_src}/thys ${lib.concatStringsSep " " sessions}
  '';

}
