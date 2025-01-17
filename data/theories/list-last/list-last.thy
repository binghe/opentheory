name: list-last
version: 1.54
description: The last list function
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: list-append
requires: list-def
requires: list-dest
requires: list-reverse
requires: list-thm
show: "Data.Bool"
show: "Data.List"

def {
  package: list-last-def-1.47
}

thm {
  import: def
  package: list-last-thm-1.42
}

main {
  import: def
  import: thm
}
