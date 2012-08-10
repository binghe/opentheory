name: parser
version: 1.83
description: Stream parsers
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: function
requires: list
requires: natural
requires: option
requires: pair
requires: relation
show: "Data.Bool"
show: "Data.List"
show: "Data.Option"
show: "Data.Pair"
show: "Function"
show: "Number.Natural"
show: "Parser"
show: "Parser.Stream"
show: "Relation"

stream {
  package: parser-stream-1.75
}

comb {
  import: stream
  package: parser-comb-1.69
}

all {
  import: stream
  import: comb
  package: parser-all-1.73
}

main {
  import: stream
  import: comb
  import: all
}
