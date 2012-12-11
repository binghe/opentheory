name: stream
version: 1.25
description: Stream types
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: function
requires: list
requires: natural
requires: pair
requires: set
show: "Data.Bool"
show: "Data.List"
show: "Data.Pair"
show: "Data.Stream"
show: "Function"
show: "Number.Natural"
show: "Set"

def {
  package: stream-def-1.24
}

thm {
  import: def
  package: stream-thm-1.25
}

main {
  import: def
  import: thm
}
