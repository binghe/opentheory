name: natural-distance
version: 1.0
description: Natural number distance function
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Number.Natural"
show: "Number.Numeral"

def {
  package: natural-distance-def-1.4
}

thm {
  import: def
  package: natural-distance-thm-1.4
}

main {
  import: def
  import: thm
}