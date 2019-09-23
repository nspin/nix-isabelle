{ stdenv, lib, hostPlatform, fetchurl, fetchMavenArtifact, fetchFromGitHub
, jdk, unzip, perl, gcc
}:

let
  pname = "sqlite-jdbc";
  version = "3.27.2.1";

  sqlite-src = fetchurl {
    url = "https://www.sqlite.org/2019/sqlite-amalgamation-3270200.zip";
    sha256 = "0jy3dfrpr7vbyijyl82xikjr9dsbqr8p2fn99lkg9rzc3ipmdz00";
  };

  jar = fetchMavenArtifact {
    groupId = "org.xerial";
    artifactId = pname;
    inherit version;
    sha256 = "0bb9xc18dv18rncbm6jw9hnmrldhqz3ncjar9gnxc7ydp4wah42b";
  };

in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "xerial";
    repo = pname;
    rev = version;
    sha256 = "1hdqirb0cvpigjxz905lm48ng0vq56canvbczq84h4cr284h61lz";
  };

  nativeBuildInputs = [
    jdk unzip perl
  ] ++ lib.optionals hostPlatform.isDarwin [
    gcc
  ];

  postPatch = ''
    patchShebangs .
  '';

  preConfigure = ''
    mkdir -p target
    ln -s ${sqlite-src} target/sqlite-3.27.2-amal.zip
  '';

  buildFlags = [
    "jni-header" "native"
  ];

  installPhase = ''
    install -D -t $out/lib target/sqlite-*/libsqlitejdbc.*
    install -D -t $out/share/java ${jar}/share/java/*.jar
  '';
}
