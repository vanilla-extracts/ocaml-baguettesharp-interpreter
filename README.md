<h1 align="center">The Baguette# OCaml Interpreter</h1>
<div align="center">
<p>
  <a href="https://github.com/coco33920/ocaml-baguettesharp-interpreter" title="Go to GitHub repo"><img src="https://img.shields.io/static/v1?label=coco33920&message=ocaml-baguettesharp-interpreter&color=55cdfc&logo=github&style=for-the-badge" alt="coco33920 - ocaml-baguettesharp-interpreter"></a>
  <a href="https://github.com/coco33920/ocaml-baguettesharp-interpreter/releases/"><img src="https://img.shields.io/github/release/coco33920/ocaml-baguettesharp-interpreter?include_prereleases=&sort=semver&color=55cdfc&style=for-the-badge" alt="GitHub release"></a>
<a href="#license"><img src="https://img.shields.io/badge/License-GPLv3-55cdfc?style=for-the-badge" alt="License"></a>
  <div align="center">
  <a href="README_fr.md">
    <img alt="FR" src="https://flagicons.lipis.dev/flags/4x3/fr.svg" width="30px" title="french-readme">
  </a>
  </div>
</p>

<h1 align="center">
    <br>
    <img src="https://i.imgur.com/iBSb0Fh.png" alt="Baguette#" width="540">
    <br>
    Baguette#
    <br>
</h1>

<a href="https://github.com/coco33920/ocaml-baguettesharp-interpreter/wiki">
<img src="https://img.shields.io/badge/Usage-Wiki-f7a8d8?style=for-the-badge">
</a>
<a href="https://ci.ocamllabs.io/github/coco33920/ocaml-baguettesharp-interpreter">
  <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fci.ocamllabs.io%2Fbadge%2Fcoco33920%2Focaml-baguettesharp-interpreter%2Fmaster&logo=ocaml&style=for-the-badge">
</a>
</div>
<h4 align="center">Baguette# is back!</h4>

## Requirements
Ocaml version >= 4.13.1, modules fmt,str and linenoise ( REPL )

```sh
opam install fmt str linenoise
```
## Installation

### Pre-compiled binaries
**Automatic download** of the linux x86_64 binaries
```bash
curl https://raw.githubusercontent.com/coco33920/ocaml-baguettesharp-interpreter/master/download.sh | sh
```
the script downloads the latest binaries (which was tagged on the releases), install it as `~/.local/bin/baguette_sharp` 
and flag it as executable. You can also do
```bash
wget https://raw.githubusercontent.com/coco33920/ocaml-baguettesharp-interpreter/master/download.sh
sh download.sh
```
Or just executing the script itself
```bash
wget https://github.com/coco33920/ocaml-baguettesharp-interpreter/releases/latest/download/baguette.linux64
mv baguette.linux64 ~/.local/bin/baguette_sharp
chmod +x ~/.local/bin/baguette_sharp
```

### OPAM
Build the latest stable version in OPAM repositories `opam install baguette_sharp` it compile and install the latest
baguette_sharp version under `baguette_sharp.repl` in OPAM files (which are in `$PATH`)

### Source
You must install the dependencies to build from sources, which are `fmt` and `linenoise`. And an OCaml version of at least 4.13.1.
An automatic script to download sources, install dependencies and build from source is available here :
```bash
curl https://raw.githubusercontent.com/coco33920/ocaml-baguettesharp-interpreter/master/automatic.sh | sh
```
Which is exactly :
```bash
opam install -y linenoise fmt
git clone https://github.com/coco33920/ocaml-baguettesharp-interpreter
cd ocaml-baguettesharp-interpreter
dune build @install
dune install
```
The script, same as OPAM, install the repl under `baguette_sharp.repl` in the OPAM files.

## History 

I restarted this project early 2022, to act as a TIPE (a french weird oral exam for the _concours_ of _Écoles d'Ingénieurs_) to frame the formal language theory, and to do that you'll play with our _world famous_ pastries !

The lexer, parser and interpreter are finished, they take a string of language and transform it into an abstract syntax tree (AST) that the interpreter take to execute the language. I now work on the theoritical part of the issue (turing-completeness), and the compiler.

The syntax is really close to a BASIC but with less explicit words and keywords you'll see :)

## Support

The language supports integers, floating point numbers, strings, booleans, predicates, gotos, conditionnals gotos (if/else), 
and implements many of the standard instructions you can find in a language standard library.
Keywords are simple and are the only instances when you don't need parenthesis, go see the WIKI for more accurate informations

## Building

```sh
dune build .
```

## Usage

```sh
dune exec baguette_sharp_interpreter
```

## Test

```sh
dune runtest
```
