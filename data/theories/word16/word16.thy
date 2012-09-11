name: word16
version: 1.88
description: 16-bit words
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: byte
requires: list
requires: natural
requires: natural-bits
requires: natural-divides
requires: pair
requires: probability
show: "Data.Bool"
show: "Data.Byte"
show: "Data.Byte.Bits"
show: "Data.List"
show: "Data.Pair"
show: "Data.Word16"
show: "Data.Word16.Bits"
show: "Number.Natural"
show: "Probability.Random"

def {
  package: word16-def-1.55
}

bits {
  import: def
  package: word16-bits-1.66
}

bytes {
  import: def
  import: bits
  package: word16-bytes-1.71
}

main {
  import: def
  import: bits
  import: bytes
}
