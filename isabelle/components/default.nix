{ lib, newScope, runCommand, linkFarm, writeText
, isabelle-src
}:

let
  mkComponent = { name, settings ? null, options ? null, components ? null, passthru ? {} }:
    runCommand "isabelle-component-${name}" {
      inherit passthru;
    } (''
      mkdir -p $out/etc
    '' + lib.optionalString (settings != null) ''
      ln -s ${writeText "settings" settings} $out/etc/settings
    '' + lib.optionalString (options != null) ''
      ln -s ${writeText "options" options} $out/etc/options
    '' + lib.optionalString (components != null) ''
      ln -s ${writeText "components" (lib.concatMapStrings (x: ''
        ${x}
      '') components)} $out/etc/components
    '');

  scope = lib.makeScope newScope (self: with self; {
    inherit mkComponent isabelle-src;
  });

  inherit (scope) callPackage;

in {
  inherit mkComponent;

  jdk = callPackage ./jdk {};
  scala = callPackage ./scala {};
  polyml = callPackage ./polyml {};

  csdp = callPackage ./csdp {};
  cvc4 = callPackage ./cvc4 {};
  eprover = callPackage ./eprover {};
  nunchaku = callPackage ./nunchaku {};
  smbc = callPackage ./smbc {};
  spass = callPackage ./spass {};
  z3 = callPackage ./z3 {};
  vampire = callPackage ./vampire {};

  jedit = callPackage ./jedit {};

  sqlite-jdbc = callPackage ./sqlite-jdbc {};

  bash-process = callPackage ./bash-process {};

  misc = callPackage ./misc.nix {};

  # WIP
  kodkodi = callPackage ./kodkodi {};
}
