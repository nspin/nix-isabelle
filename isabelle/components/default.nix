{ callPackage }:

{
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
  kodkodi = callPackage ./kodkodi {};
  stack = callPackage ./stack {};
  opam = callPackage ./opam {};
}
