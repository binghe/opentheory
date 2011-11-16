name: list-take-drop
version: 1.23
description: Definitions and theorems about the list take and drop functions
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Data.List"
show: "Number.Natural"

def {
  package: list-take-drop-def-1.23
}

thm {
  import: def
  package: list-take-drop-thm-1.24
}

main {
  import: def
  import: thm
}
