{ stdenv, lib, hostPlatform, callPackage, fetchhg, writeText, runCommand
, perl, coreutils
}:

with lib;

let

  src = fetchhg {
    url = "https://isabelle.in.tum.de/repos/isabelle";
    rev = "Isabelle2019";
    sha256 = "0pwlc72dcyx4k1gi57xgwlakc3zhd8kfgk9inap73brxy2lbhx34";
  };

  components = callPackage ./components {
    isabelle-src = src;
  };

  prebuiltComponents = callPackage ./prebuilt-components {};
  getPrebuiltComponents = names: attrValues (getAttrs names prebuiltComponents);

  metaComponent = components.mkComponent {
    name = "meta";
    components = getPrebuiltComponents [

      # Just perl scripts and data, but with shebangs
      "bib2xhtml-20190409"

      # Just fonts
      "isabelle_fonts-20190409"

      # Pure Java
      "jfreechart-1.5.0"
      "jortho-1.0-2"
      "postgresql-42.2.5"
      "ssh-java-20190323"
      "xz-java-1.8"

    ] ++ (with components; [

      jdk
      scala
      polyml

      csdp
      cvc4
      eprover
      nunchaku
      kodkodi
      smbc
      spass
      z3
      vampire

      jedit

      sqlite-jdbc

      bash-process

      misc

    ]);
  };

  home = stdenv.mkDerivation {
    pname = "isabelle";
    version = "2019";
    inherit src;

    patches = [
      ./patches/fix-jedit-build-permissions.patch
    ] ++ lib.optionals (hostPlatform.isAarch64) [
      ./patches/add-platform-aarch64.patch
    ];

    phases = [ "unpackPhase" "patchPhase" "configurePhase" "buildPhase" ];

    nativeBuildInputs = [ perl ];

    unpackPhase = ''
      cp -r $src $out
      chmod -R u+w $out
      cd $out
    '';

    postPatch = ''
      patchShebangs .

      find . -type f -exec sed -i 's|/usr/bin/env|${coreutils}/bin/env|g' {} ';'

      substituteInPlace etc/options \
        --replace \
          'public option ML_system_64 : bool = false' \
          'public option ML_system_64 : bool = true'
    '' + lib.optionalString (hostPlatform.isAarch64) ''
      substituteInPlace etc/options \
        --replace \
          'option timeout : real = 0'  \
          'option timeout : real = 1048576' \
        --replace \
          'option timeout_scale : real = 1.0' \
          'option timeout_scale : real = 1048576.0'

      substituteInPlace src/HOL/SMT.thy \
        --replace \
          'smt_timeout = 20' \
          'smt_timeout = 1048576'
    '';


    configurePhase = ''
      echo ${metaComponent} >> etc/components
      export HOME=$TMP
    '';

    buildPhase = ''
      ./Admin/build all
      ./bin/isabelle jedit -b
    '';
      # (see Admin/jenkins/run_build)
      # ./bin/isabelle ocaml_setup
      # ./bin/isabelle ghc_setup
  };

  tests = callPackage ./tests {
    inherit isabelle;
  };

  isabelle = runCommand "isabelle-2019-bin" {
    passthru = {
      inherit home components prebuiltComponents tests;
    };
  } ''
    mkdir -p $out/bin
    ln -s ${home}/bin/* $out/bin
  '';

in
isabelle
