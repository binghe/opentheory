name: byte
version: 1.21
description: Basic theory of bytes
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Data.Byte"
show: "Data.List"
show: "Number.Natural" as "Natural"

def {
  package: byte-def-1.1
}

word {
  import: def
  interpret: type "Data.Word.word" as "Data.Byte.byte"
  interpret: const "Data.Word.*" as "Data.Byte.*"
  interpret: const "Data.Word.+" as "Data.Byte.+"
  interpret: const "Data.Word.-" as "Data.Byte.-"
  interpret: const "Data.Word.<" as "Data.Byte.<"
  interpret: const "Data.Word.<=" as "Data.Byte.<="
  interpret: const "Data.Word.~" as "Data.Byte.~"
  interpret: const "Data.Word.and" as "Data.Byte.and"
  interpret: const "Data.Word.bit" as "Data.Byte.bit"
  interpret: const "Data.Word.fromNatural" as "Data.Byte.fromNatural"
  interpret: const "Data.Word.modulus" as "Data.Byte.modulus"
  interpret: const "Data.Word.not" as "Data.Byte.not"
  interpret: const "Data.Word.or" as "Data.Byte.or"
  interpret: const "Data.Word.shiftLeft" as "Data.Byte.shiftLeft"
  interpret: const "Data.Word.shiftRight" as "Data.Byte.shiftRight"
  interpret: const "Data.Word.toNatural" as "Data.Byte.toNatural"
  interpret: const "Data.Word.width" as "Data.Byte.width"
  interpret: const "Data.Word.Bits.compare" as "Data.Byte.Bits.compare"
  interpret: const "Data.Word.Bits.fromWord" as "Data.Byte.Bits.fromWord"
  interpret: const "Data.Word.Bits.normal" as "Data.Byte.Bits.normal"
  interpret: const "Data.Word.Bits.toWord" as "Data.Byte.Bits.toWord"
  package: word-1.21
}

bits {
  import: def
  import: word
  package: byte-bits-1.20
}

main {
  import: def
  import: word
  import: bits
}
