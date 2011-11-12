name: gfp-inverse
version: 1.1
description: GF(p) inverse
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
show: "Data.Bool"

def {
  package: gfp-inverse-def-1.1
}

thm {
  import: def
  package: gfp-inverse-thm-1.1
}

main {
  import: def
  import: thm
}