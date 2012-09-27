name: group-mult-add-thm
version: 1.4
description: Correctness of group multiplication by repeated addition
author: Joe Hurd <joe@gilith.com>
license: MIT
provenance: HOL Light theory extracted on 2012-09-25
requires: bool
requires: group-mult-add-def
requires: group-mult-def
requires: group-mult-thm
requires: group-thm
requires: group-witness
requires: list
requires: natural
requires: natural-bits
show: "Algebra.Group"
show: "Data.Bool"
show: "Data.List"
show: "Number.Natural"

main {
  article: "group-mult-add-thm.art"
}
