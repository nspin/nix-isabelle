{ mkComponent, stdenv, lib, callPackage, runCommand, fetchurl }:

with lib;

let
  jedit = callPackage ./jedit.nix {
    inherit bcpg jsr305;
  };

  bcpg = fetchurl {
    url = http://central.maven.org/maven2/org/bouncycastle/bcpg-jdk16/1.46/bcpg-jdk16-1.46.jar;
    sha256 = "16xhmwks4l65m5x150nd23y5lyppha9sa5fj65rzhxw66gbli82d";
  };

  jsr305 = fetchurl {
    url = http://central.maven.org/maven2/com/google/code/findbugs/jsr305/2.0.0/jsr305-2.0.0.jar;
    sha256 = "0s74pv8qjc42c7q8nbc0c3b1hgx0bmk3b8vbk1z80p4bbgx56zqy";
  };

  idea-icons = stdenv.mkDerivation {
    name = "idea-icons.jar";
    phases = [ "unpackPhase" "installPhase" ];
    src = fetchurl {
      url = "https://isabelle.in.tum.de/components/jedit_build-20190508.tar.gz";
      sha256 = "510603e5594ecf2d609c5343d61b09c15dc5421e73eeef027e8014a91a772a5b";
    };
    installPhase = ''
      mv contrib/idea-icons.jar $out
    '';
  };

  mkPlugin = name: sha256:
    let
      src = fetchurl {
        url = "http://prdownloads.sourceforge.net/jedit-plugins/${name}-bin.tgz";
        inherit sha256;
      };
    in runCommand name {} ''
      mkdir $out
      tar -xz -C $out -f ${src}
    '';

  plugins = mapAttrsToList mkPlugin (import ./plugins/hashes.nix);

  quick-notepad = mkPlugin "QuickNotepad-5.0" "1yyh801ljr111inznr26fjfz97akp7dqiy1ihgzs8dfbv17nyn3z";

  home = runCommand "jedit-build-home" {} ''
    mkdir -p $out/contrib

    ${concatMapStrings (plugin: ''
      ln -s ${plugin}/* $out/contrib
    '') plugins}

    ln -s ${jsr305}     $out/contrib/jsr305-2.0.0.jar
    ln -s ${idea-icons} $out/contrib/idea-icons.jar

    mkdir -p                 $out/contrib/${jedit.name}/jars
    ln -s ${jedit}/*         $out/contrib/${jedit.name}
    ln -s ${quick-notepad}/* $out/contrib/${jedit.name}/jars

    mkdir -p $out/doc
    touch $out/doc/jedit5.5.0manual-a4.pdf
  '';

in
mkComponent {
  name = "jedit_build";
  settings = ''
    ISABELLE_JEDIT_BUILD_HOME=${home}
    ISABELLE_JEDIT_BUILD_VERSION=${jedit.name}
  '';
  passthru = {
    inherit jedit;
  };
}
