{ mkComponent, spass }:

mkComponent {
  inherit (spass) name;
  settings = ''
    SPASS_HOME=${spass}/bin
    SPASS_VERSION=${spass.version}
  '';
  passthru = {
    inherit spass;
  };
}
