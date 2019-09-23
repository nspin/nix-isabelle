{ stdenv, lib, fetchurl, makeWrapper, setJavaClassPath
, file
, glib, libxml2, libav_0_8, ffmpeg, libxslt, libGL
, xorg, alsaLib, fontconfig, freetype, pango, gtk2, cairo, gdk_pixbuf, atk
}:

let
  rSubPaths = [
    "lib"
    "lib/jli"
    "lib/server"
    "lib/xawt"
  ];

  libraries = [
    stdenv.cc.libc glib libxml2 libav_0_8 ffmpeg libxslt libGL
    xorg.libXxf86vm alsaLib fontconfig freetype pango gtk2 cairo gdk_pixbuf atk
  ];

  rpath = lib.strings.makeLibraryPath libraries;

  self = stdenv.mkDerivation {
    name = "zulu-openjdk-11-binary";
    src = fetchurl {
      url = "http://cdn.azul.com/zulu-embedded/bin/zulu11.31.15-ca-jdk11.0.3-linux_aarch64.tar.gz";
      sha256 = "16z65a4592dlybciph4gz04sxx77y2sfmygwk904vp0v3dhr239v";
    };

    phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

    nativeBuildInputs = [ file ];
    buildInputs = [ makeWrapper ];
    dontStrip = true;

    inherit rpath;

    installPhase = ''
      mkdir $out
      mv bin include lib $out

      mkdir -p $out/nix-support
      printWords ${setJavaClassPath} > $out/nix-support/propagated-build-inputs

      cat <<EOF >> $out/nix-support/setup-hook
      if [ -z "\$JAVA_HOME" ]; then export JAVA_HOME=$out; fi
      EOF
    '';

    postFixup = ''
      rpath="$rpath${lib.concatMapStrings (x: ":$out/${x}") rSubPaths}"

      find $out -type f -executable -exec \
        patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "$rpath" {} \;

      find $out -name "*.so" -exec patchelf --set-rpath "$rpath" {} \;
    '';

    passthru = {
      home = self;
    };
  };

in self
