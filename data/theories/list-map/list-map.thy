name: list-map
version: 1.42
description: The list map function
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: function
requires: list-append
requires: list-def
requires: list-dest
requires: list-length
requires: list-set
requires: list-thm
requires: set
show: "Data.Bool"
show: "Data.List"
show: "Function"
show: "Number.Natural"
show: "Set"

def {
  package: list-map-def-1.38
}

thm {
  import: def
  package: list-map-thm-1.49
}

main {
  import: def
  import: thm
}
