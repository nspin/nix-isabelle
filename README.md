# nix-isabelle

Isabelle depends on old versions of many third-party tools. Due to the difficulty of packaging and composing all of these dependencies, Isabelle is normally distributed as binary artifacts rather than source.

This repository contains Nix expressions which package Isabelle and all of its components from source, without any prebuilt platform-specific binary artifacts.

Packaging from source has allowed me to run Isabelle on aarch64. Doing so is not officially supported by Isabelle, but required only a tiny [patch](./isabelle/patches/add-platform-aarch64.patch). However, Isabelle on aarch64 is disproportionately slow. I suspect this is due to sub-optimal PolyML codegen.

### Getting Started

Ensure the Nix package manager is installed.

```
$ nix-build -A isabelle
$ ./result/bin/isabelle
```

### Status

This package seems to be working on `x86_64-linux`, `aarch64-linux`(!), and `x86_64-darwin`. I plan on testing it on `x86_64-freebsd` as well.

I've yet to successfully build the entire Isabelle standard library and [Archive of Formal Proofs](https://www.isa-afp.org/). That's what I'm working on now.

The Isabelle [expression](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/science/logic/isabelle/default.nix) in upstream nixpkgs applies `patchelf` to the binary Isabelle distribution. I plan on proposing to replace it with the Isabelle expression in this repository.
