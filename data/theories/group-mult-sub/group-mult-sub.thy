name: group-mult-sub
version: 1.6
description: Group multiplication by repeated subtraction
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: group-def
requires: group-mult-def
requires: group-mult-thm
requires: group-thm
requires: group-witness
requires: list
requires: natural
requires: natural-fibonacci
show: "Algebra.Group"
show: "Data.Bool"
show: "Data.List"
show: "Number.Natural"

def {
  package: group-mult-sub-def-1.10
}

thm {
  import: def
  package: group-mult-sub-thm-1.8
}

main {
  import: def
  import: thm
}