{ mkComponent, callPackage, z3 }:

let
  vampire = callPackage ./vampire.nix {
    z3 = z3-no-meta;
  };

  z3-no-meta = z3.overrideAttrs (attrs: {
    meta = {};
  });

in
mkComponent {
  name = "vampire-4.2.2";
  settings = ''
    VAMPIRE_HOME=${vampire}/bin
    VAMPIRE_VERSION=${vampire.version}
    VAMPIRE_EXTRA_OPTIONS="--mode casc"
  '';
  passthru = {
    inherit vampire;
  };
}
