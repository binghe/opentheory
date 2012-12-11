name: set-finite
version: 1.48
description: Finite sets
author: Joe Leslie-Hurd <joe@gilith.com>
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
  package: set-finite-def-1.33
}

thm {
  import: def
  package: set-finite-thm-1.54
}

main {
  import: def
  import: thm
}
