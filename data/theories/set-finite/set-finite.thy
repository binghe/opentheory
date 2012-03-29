name: set-finite
version: 1.34
description: Finite sets
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: function
requires: natural
requires: pair
requires: set-def
requires: set-thm
show: "Data.Bool"
show: "Data.Pair"
show: "Function"
show: "Number.Natural"
show: "Set"

def {
  package: set-finite-def-1.21
}

thm {
  import: def
  package: set-finite-thm-1.39
}

main {
  import: def
  import: thm
}
