name: natural-gcd
version: 1.52
description: Natural number greatest common divisor
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: natural
requires: natural-divides
show: "Data.Bool"
show: "Number.Natural"

def {
  package: natural-gcd-def-1.41
}

thm {
  import: def
  package: natural-gcd-thm-1.49
}

lcm {
  import: def
  import: thm
  package: natural-gcd-lcm-1.38
}

main {
  import: def
  import: thm
  import: lcm
}
