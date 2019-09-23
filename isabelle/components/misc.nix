{ mkComponent, haskellPackages, opam, rlwrap }:

mkComponent {
  name = "misc";
  settings = ''
    ISABELLE_STACK=${haskellPackages.stack}/bin/stack
    ISABELLE_OPAM=${opam}/bin/opam
    ISABELLE_LINE_EDITOR=${rlwrap}/bin/rlwrap
  '';
}
