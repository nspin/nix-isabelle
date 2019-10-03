{ mkComponent, opam }:

mkComponent {
  name = "opam";
  settings = ''
    ISABELLE_OPAM=${opam}/bin/opam
  '';
}
