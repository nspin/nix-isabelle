{ callPackage }:

{
  bash-process = callPackage ./bash-process {};
  csdp = callPackage ./csdp {};
  cvc4 = callPackage ./cvc4 {};
  eprover = callPackage ./eprover {};
  jdk = callPackage ./jdk {};
  jedit = callPackage ./jedit {};
  kodkodi = callPackage ./kodkodi {};
  nunchaku = callPackage ./nunchaku {};
  opam = callPackage ./opam {};
  polyml = callPackage ./polyml {};
  scala = callPackage ./scala {};
  smbc = callPackage ./smbc {};
  spass = callPackage ./spass {};
  sqlite-jdbc = callPackage ./sqlite-jdbc {};
  stack = callPackage ./stack {};
  vampire = callPackage ./vampire {};
  z3 = callPackage ./z3 {};
}
