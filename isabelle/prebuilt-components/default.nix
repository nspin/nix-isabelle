{ lib, runCommand, fetchurl }:

with lib;

let
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
      # for f in contrib/*/$platform/{bash_process,epclextract,eprover,nunchaku,SPASS}; do
      #   patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f"
      # done

in
mapAttrs mkPrebuiltComponent (import ./hashes.nix)
