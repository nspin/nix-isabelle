{ stdenv, fetchurl, makeWrapper, jre, gnugrep, coreutils }:

stdenv.mkDerivation rec {
  name = "scala-2.12.7";

  src = fetchurl {
    url = "https://www.scala-lang.org/files/archive/${name}.tgz";
    sha256 = "116i6sviziynbm7yffakkcnzb2jmrhvjrnbqbbnhyyi806shsnyn";
  };

  propagatedBuildInputs = [ jre ] ;
  buildInputs = [ makeWrapper ] ;

  installPhase = ''
    mkdir -p $out
    rm bin/*.bat
    mv * $out

    mkdir -p $out/share/doc
    mv $out/doc $out/share/doc/scala

    for p in $(ls $out/bin); do
      wrapProgram $out/bin/$p \
        --prefix PATH ":" ${coreutils}/bin \
        --prefix PATH ":" ${gnugrep}/bin \
        --prefix PATH ":" ${jre}/bin \
        --set JAVA_HOME ${jre}
    done
  '';
}
