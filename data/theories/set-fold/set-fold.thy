name: set-fold
version: 1.37
description: A fold operation on finite sets
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: natural
requires: set-finite
requires: set-thm
show: "Data.Bool"
show: "Number.Natural"
show: "Set"

def {
  package: set-fold-def-1.44
}

thm {
  import: def
  package: set-fold-thm-1.34
}

main {
  import: def
  import: thm
}
