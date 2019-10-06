# nix-isabelle

Isabelle depends on old versions of many third-party tools. Due to the difficulty of packaging and composing all of these dependencies, Isabelle is normally distributed as binary artifacts rather than source.

This repository contains Nix expressions which package Isabelle and all of its components from source, without any prebuilt platform-specific binary artifacts.

Packaging from source has allowed me to run Isabelle on aarch64. Doing so is not officially supported by Isabelle, but required only a tiny [patch](./isabelle/patches/add-platform-aarch64.patch). However, Isabelle on aarch64 is disproportionately slow. I suspect this is due to sub-optimal PolyML codegen.

### Usage

Build Isabelle:
```
$ nix-build -A isabelle
$ ./result/bin/isabelle version
```

Install Isabelle:
```
$ nix-env -f . -iA isabelle
$ isabelle version
```

Build the sessions that ship with Isabelle in a sandbox.
This will skip the `Haskell` session, which uses Stack and cannot be run in a sandbox.
```
$ nix-build -A tests.lib
```

Build AFP within a Nix shell:
```
$ nix-shell -A tests.shell
[nix-shell]$ setup # symlink from $ISABELLE_HOME_USER/etc/preferences (see ./tests/default.nix)
[nix-shell]$ isabelle ghc_setup
[nix-shell]$ isabelle ocaml_setup
[nix-shell]$ isabelle build -d $afp -a
```

### Status

I've built the entire [Archive of Formal Proofs](https://www.isa-afp.org/) except for three sessions (`Native_Word` due to lack of memory, and `Projective_Geometry` and `Iptables_Semantics_Examples_Big` for unknown reasons) on `x86_64-linux` using this package.
I've also built all sessions that ship with Isabelle on `x86_64-darwin` using this package.
I expect AFP would build on Darwin with equal success as on Linux, but I haven't yet had the chance to test it.

Success on `aarch64-linux` has been limited by some components' issues on `aarch64`.  Perhaps most importantly, it seems that PolyML's codegen for aarch64 may not have received the same optimization treatment as that for x86. Also, versions of Z3 ranging from 4.4.0 to 4.8.5 (current at time of writing) hang or segfault on some Isabelle-generated SMT. However, all else seems to working fine for basis use.

I have not tested this package on `x86_64-*bsd`. However, this work is at the very least a good starting point for an Isabelle distribution for a BSD.

The Isabelle [expression](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/science/logic/isabelle/default.nix) in upstream nixpkgs applies `patchelf` to the binary Isabelle distribution. I plan on proposing to replace it with the Isabelle expression in this repository.
