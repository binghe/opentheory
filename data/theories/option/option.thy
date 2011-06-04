name: option
version: 1.6
description: Basic theory of option types
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Data.Option"
show: "Number.Natural"
show: "Number.Numeral"

def {
  package: option-def-1.2
}

thm {
  import: def
  package: option-thm-1.2
}

dest {
  import: def
  import: thm
  package: option-dest-1.4
}

main {
  import: def
  import: thm
  import: dest
}
