{ mkComponent, lib, csdp }:

assert !(lib.versionOlder "6.1.1" (lib.getVersion csdp.name));

mkComponent {
  inherit (csdp) name;
  settings = ''
    ISABELLE_CSDP=${csdp}/bin/csdp
  '';
}
