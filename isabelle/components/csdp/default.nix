{ mkComponent, csdp }:

mkComponent {
  inherit (csdp) name;
  settings = ''
    ISABELLE_CSDP=${csdp}/bin/csdp
  '';
}
