{ mkComponent, lib, hostPlatform, haskellPackages, opam, rlwrap, swiProlog }:

mkComponent {
  name = "misc";
  settings = ''
    ISABELLE_STACK=${haskellPackages.stack}/bin/stack
    ISABELLE_OPAM=${opam}/bin/opam
    ISABELLE_LINE_EDITOR=${rlwrap}/bin/rlwrap
  '' + lib.optionalString hostPlatform.isLinux ''
    ISABELLE_SWIPL=${swiProlog}/bin/swipl
  '';
}
