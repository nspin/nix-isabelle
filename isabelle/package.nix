{ stdenv, lib, hostPlatform, callPackage, callPackages, newScope
, writeText, runCommand, fetchurl, fetchhg
, perl, coreutils
, rlwrap, mlton, smlnj, swiProlog
, extraComponents ? []
, extraSettings ? ""
}:

let

  isabelle_src = fetchhg {
    url = "https://isabelle.in.tum.de/repos/isabelle";
    rev = "Isabelle2019";
    sha256 = "0pwlc72dcyx4k1gi57xgwlakc3zhd8kfgk9inap73brxy2lbhx34";
  };

  mkComponent = { name, settings ? null, options ? null, components ? null, passthru ? {} }:
    runCommand "isabelle-component-${name}" {
      inherit passthru;
    } (''
      mkdir -p $out/etc
    '' + lib.optionalString (settings != null) ''
      ln -s ${writeText "settings" settings} $out/etc/settings
    '' + lib.optionalString (options != null) ''
      ln -s ${writeText "options" options} $out/etc/options
    '' + lib.optionalString (components != null) ''
      ln -s ${writeText "components" (lib.concatMapStrings (x: ''
        ${x}
      '') components)} $out/etc/components
    '');

  mkPrebuiltComponent = name: sha256:
    let
      tarball = fetchurl {
        url = "https://isabelle.in.tum.de/components/${name}.tar.gz";
        inherit sha256;
      };
    in runCommand "isabelle-prebuilt-${name}" {} ''
      tar -xzf ${tarball}
      mv ${name} $out
    '';

  components =
    # lib.makeScope doesn't add 'callPackages' and we want a raw attrset
    let
      scope = lib.makeScope newScope (self: {
        inherit mkComponent isabelle_src;
      });
    in import ./components {
      inherit (scope) callPackage;
    };

  prebuiltComponents = callPackage ./prebuilt-components {
    inherit mkPrebuiltComponent;
  };

  metaComponent = mkComponent {
    name = "meta";
    components = lib.attrValues (prebuiltComponents.main // components) ++ extraComponents;
    settings = ''
      ISABELLE_LINE_EDITOR=${rlwrap}/bin/rlwrap
      ISABELLE_MLTON=${mlton}/bin/mlton
    '' + lib.optionalString hostPlatform.isLinux ''
      ISABELLE_SMLNJ=${smlnj}/bin/sml
      ISABELLE_SWIPL=${swiProlog}/bin/swipl
    '' + extraSettings;
  };

  home = stdenv.mkDerivation {
    pname = "isabelle";
    version = "2019";
    src = isabelle_src;

    patches = [
      ./patches/fix-jedit-build-permissions.patch
      ./patches/rw-mirabelle-example.patch
    ] ++ lib.optionals (hostPlatform.isAarch64) [
      ./patches/add-platform-aarch64.patch
    ];

    phases = [ "unpackPhase" "patchPhase" "configurePhase" "buildPhase" ];

    nativeBuildInputs = [ perl ];

    unpackPhase = ''
      cp -r $src $out
      chmod -R u+w $out
      sourceRoot=$out
    '';

    postPatch = ''
      patchShebangs .

      find . -type f -exec sed -i 's|/usr/bin/env|${coreutils}/bin/env|g' {} ';'

      cp ${./patches/smt-example-certs}/* src/HOL/SMT_Examples
    '';

    configurePhase = ''
      echo ${metaComponent} >> etc/components
      export HOME=$TMP
    '';

    buildPhase = ''
      ./Admin/build all
      ./bin/isabelle jedit -b
    '';
  };

  isabelle = runCommand "isabelle-2019-bin" {
    passthru = {
      inherit home components prebuiltComponents mkComponent mkPrebuiltComponent;
    };
  } ''
    mkdir -p $out/bin
    ln -s ${home}/bin/* $out/bin
  '';

in
isabelle
