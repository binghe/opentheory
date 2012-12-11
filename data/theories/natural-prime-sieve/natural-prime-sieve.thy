name: natural-prime-sieve
version: 1.21
description: The sieve of Eratosthenes
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: function
requires: list
requires: natural
requires: natural-divides
requires: natural-prime-stream
requires: pair
requires: relation
requires: stream
show: "Data.Bool"
show: "Data.List"
show: "Data.Pair"
show: "Data.Stream"
show: "Function"
show: "Number.Natural"
show: "Number.Natural.Prime.Sieve"

def {
  package: natural-prime-sieve-def-1.25
}

thm {
  import: def
  package: natural-prime-sieve-thm-1.24
}

main {
  import: def
  import: thm
}
