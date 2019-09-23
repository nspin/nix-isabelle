{ stdenv, lib, fetchurl, bash, cpio, autoconf, pkgconfig, file, which, unzip, zip, cups, freetype
, alsaLib, bootjdk, perl, liberation_ttf, fontconfig, zlib, lndir
, libX11, libICE, libXrender, libXext, libXt, libXtst, libXi, libXinerama, libXcursor, libXrandr
, libjpeg, giflib
, setJavaClassPath
}:

let

  architecture = "aarch64-linx";

  major = "11";
  update = ".0.3";
  build = "ga";
  repover = "jdk-${major}${update}-${build}";

  openjdk = stdenv.mkDerivation {
    name = "openjdk-${major}${update}-${build}";

    src = fetchurl {
      url = "http://hg.openjdk.java.net/jdk-updates/jdk${major}u/archive/${repover}.tar.gz";
      sha256 = "1v6pam38iidlhz46046h17hf5kki6n3kl302awjcyxzk7bmkvb8x";
    };

    nativeBuildInputs = [ pkgconfig ];
    buildInputs = [
      autoconf cpio file which unzip zip perl bootjdk zlib cups freetype alsaLib
      libjpeg giflib libX11 libICE libXext libXrender libXtst libXt libXtst
      libXi libXinerama libXcursor libXrandr lndir fontconfig
    ];

    patches = [
      ./patches/fix-java-home-jdk10.patch
      ./patches/read-truststore-from-env-jdk10.patch
      ./patches/currency-date-range-jdk10.patch
    ];

    preConfigure = ''
      chmod +x configure
      patchShebangs configure
    '';

    configureFlags = [
      "--with-boot-jdk=${bootjdk.home}"

      "--with-update-version=${major}${update}"
      "--with-build-number=${build}"
      "--with-milestone=fcs"
      "--enable-unlimited-crypto"
      "--disable-debug-symbols"

      # "--enable-unlimited-crypto"
      "--with-zlib=system"
      "--with-giflib=system"
      "--with-stdc++lib=dynamic"

      # glibc 2.24 deprecated readdir_r so we need this
      # See https://www.mail-archive.com/openembedded-devel@lists.openembedded.org/msg49006.html
      # "--with-extra-cflags='-Wno-error=deprecated-declarations -Wno-error=format-contains-nul -Wno-error=unused-result'"
      # "--with-extra-cxxflags=-std=gnu++98"
    ];


    # NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isGNU [
    # "-std=gnu++98"

    # # https://bugzilla.redhat.com/show_bug.cgi?id=1306558
    # # https://github.com/JetBrains/jdk8u/commit/eaa5e0711a43d64874111254d74893fa299d5716
    NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isGNU [
      "-std=gnu++98" "-fno-lifetime-dse" "-fno-delete-null-pointer-checks" "-Wno-error"
    ];

    NIX_LDFLAGS= [
      "-lfontconfig" "-lcups" "-lXinerama" "-lXrandr" "-lmagic"
    ];

    buildFlags = [ "all" ];

    installPhase = ''
      mkdir -p $out/lib/openjdk $out/share

      cp -av build/*/images/jdk/* $out/lib/openjdk

      # Remove some broken manpages.
      rm -rf $out/lib/openjdk/man/ja*

      # Mirror some stuff in top-level.
      mkdir $out/include $out/share/man
      ln -s $out/lib/openjdk/include/* $out/include/
      ln -s $out/lib/openjdk/man/* $out/share/man/

      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/linux/*_md.h $out/include/

      # Remove crap from the installation.
      rm -rf $out/lib/openjdk/demo

      ln -s $out/lib/openjdk/bin $out/bin
    '';

    preFixup = ''
      # Propagate the setJavaClassPath setup hook so that any package
      # that depends on the JDK has $CLASSPATH set up properly.
      mkdir -p $out/nix-support
      #TODO or printWords?  cf https://github.com/NixOS/nixpkgs/pull/27427#issuecomment-317293040
      echo -n "${setJavaClassPath}" > $out/nix-support/propagated-build-inputs

      # Set JAVA_HOME automatically.
      mkdir -p $out/nix-support
      cat <<EOF > $out/nix-support/setup-hook
      if [ -z "\$JAVA_HOME" ]; then export JAVA_HOME=$out/lib/openjdk; fi
      EOF
    '';

    postFixup = ''
      # Build the set of output library directories to rpath against
      LIBDIRS=""
      for output in $outputs; do
        LIBDIRS="$(find $(eval echo \$$output) -name \*.so\* -exec dirname {} \+ | sort | uniq | tr '\n' ':'):$LIBDIRS"
      done

      # Add the local library paths to remove dependencies on the bootstrap
      for output in $outputs; do
        OUTPUTDIR=$(eval echo \$$output)
        BINLIBS=$(find $OUTPUTDIR/bin/ -type f; find $OUTPUTDIR -name \*.so\*)
        echo "$BINLIBS" | while read i; do
          patchelf --set-rpath "$LIBDIRS:$(patchelf --print-rpath "$i")" "$i" || true
          patchelf --shrink-rpath "$i" || true
        done
      done

      # Test to make sure that we don't depend on the bootstrap
      for output in $outputs; do
        if grep -q -r '${bootjdk}' $(eval echo \$$output); then
          echo "Extraneous references to ${bootjdk} detected"
          exit 1
        fi
      done
    '';

    passthru = {
      inherit architecture;
      home = "${openjdk}/lib/openjdk";
    };
  };
in openjdk
