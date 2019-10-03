{ stdenv, callPackage, fetchurl, ant, jdk, commonsBsf, commonsLogging, bsh
, isabelle_src, bcpg, jsr305
}:

stdenv.mkDerivation rec{
  pname = "jedit";
  version = "5.5.0";

  src = fetchurl {
    url = "mirror://sourceforge/jedit/jedit${version}source.tar.bz2";
    sha256 = "1ifyaw1hkbq9p69swb022zg25xjhpmvfzbqgyiypnziv0pszrl8b";
  };

  buildInputs = [ ant jdk commonsBsf commonsLogging ];

  patches = [
    # This patch removes from the build process:
    #  - the automatic download of dependencies (see configurePhase);
    #  - the tests
    ./build.xml.patch
  ];

  prePatch = ''
    mkdir patches
    cp ${isabelle_src}/src/Tools/jEdit/patches/* patches
    for patch in patches/*; do
      if [ $patch = patches/macosx ]; then
        :
      else
        substituteInPlace $patch \
          --replace "--- 5.5.0/jEdit" "--- a" \
          --replace "+++ 5.5.0/jEdit-patched" "+++ b"
        export patches="$patches $patch"
      fi
    done
    echo $patches
  '';
        # --replace "--- MacOSX-trunk-r24891" "--- a" \
        # --replace "+++ MacOSX-trunk" "+++ b"

  configurePhase = ''
    install -D -t lib/ant-contrib ${ant}/lib/ant/lib/ant-contrib-*.jar
    install -D -t lib/scripting ${bsh} ${bcpg}
    install -D -t lib/compile ${jsr305}
    mkdir -p lib/default-plugins
  '';

  buildPhase = ''
    ant build
  '';

  installPhase = ''
    mkdir $out
    mv build/jedit.jar doc icons keymaps macros modes properties startup $out
  '';

  dontFixup = true;
}
