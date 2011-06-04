name: natural-order
version: 1.2
description: Definitions and theorems about natural number orderings
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Number.Natural"
show: "Number.Numeral"

def {
  package: natural-order-def-1.1
}

thm {
  import: def
  package: natural-order-thm-1.2
}

main {
  import: def
  import: thm
}
