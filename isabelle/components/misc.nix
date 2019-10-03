{ mkComponent, lib, hostPlatform, haskellPackages, haskell, ocamlPackages
, opam, rlwrap
, mlton, smlnj, swiProlog
}:

mkComponent {
  name = "misc";
  settings = ''
    ISABELLE_MLTON=${mlton}/bin/mlton
    ISABELLE_GHC_VERSION=ghc-8.4.4
    ISABELLE_GHC=${haskell.packages.ghc844.ghc}/bin/ghc
    ISABELLE_STACK=${haskellPackages.stack}/bin/stack
    ISABELLE_OPAM=${opam}/bin/opam
    ISABELLE_LINE_EDITOR=${rlwrap}/bin/rlwrap
  ''
  # TODO
  + lib.optionalString hostPlatform.isLinux ''
    ISABELLE_SMLNJ=${smlnj}/bin/sml
    ISABELLE_SWIPL=${swiProlog}/bin/swipl
  '';
    # TODO HOL-Codegenerator_Test depends on zarith
    # ISABELLE_OCAMLFIND=${ocamlPackages.findlib}/bin/ocamlfind
}
