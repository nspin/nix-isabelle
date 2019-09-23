{ mkComponent, callPackage }:

let
  bash-process = callPackage ./bash-process.nix {};

in
mkComponent {
  inherit (bash-process) name;
  settings = ''
    ISABELLE_BASH_PROCESS=${bash-process}
  '';
  passthru = {
    inherit bash-process;
  };
}
