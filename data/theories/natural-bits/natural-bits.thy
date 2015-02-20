name: natural-bits
version: 1.52
description: Natural number to bit-list conversions
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: base
requires: probability
show: "Data.Bool"
show: "Data.List"
show: "Data.Pair"
show: "Function"
show: "Number.Natural"
show: "Probability.Random"
haskell-name: opentheory-bits
haskell-int-file: haskell.int
haskell-src-file: haskell.art

def {
  package: natural-bits-def-1.27
}

thm {
  import: def
  package: natural-bits-thm-1.44
}

main {
  import: def
  import: thm
}
