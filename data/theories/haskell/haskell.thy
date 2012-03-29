name: haskell
version: 1.11
description: The Haskell base
author: Joe Hurd <joe@gilith.com>
license: MIT
provenance: HOL Light theory extracted on 2012-02-26
show: "Data.Bool"
requires: base
show: "Data.Bool"
show: "Data.List"
show: "Data.Option"

def {
  package: haskell-def-1.13
}

thm {
  import: def
  package: haskell-thm-1.13
}

main {
  import: def
  import: thm
}
