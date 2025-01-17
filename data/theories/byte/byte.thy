name: byte
version: 1.135
description: Bytes
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
homepage: https://opentheory.gilith.com/?pkg=byte
requires: base
requires: natural-bits
requires: natural-divides
requires: probability
show: "Data.Bool"
show: "Data.Byte"
show: "Data.Byte.Bits"
show: "Data.List"
show: "Number.Natural"
show: "Probability.Random"
hol-light-int-file: hol-light.int
hol-light-thm-file: hol-light.art
haskell-int-file: haskell.int
haskell-src-file: haskell.art
haskell-equality-type: "Data.Byte.byte"
haskell-arbitrary-type: "Data.Byte.byte"

def {
  package: byte-def-1.100
}

bits {
  import: def
  package: byte-bits-1.83
}

main {
  import: def
  import: bits
}
