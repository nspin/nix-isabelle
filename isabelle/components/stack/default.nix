{ mkComponent, haskellPackages }:

mkComponent {
  name = "stack";
  settings = ''
    ISABELLE_STACK=${haskellPackages.stack}/bin/stack
  '';
}
