(* ========================================================================= *)
(* CHECKSUMS                                                                 *)
(* Copyright (c) 2010 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature Checksum =
sig

(* ------------------------------------------------------------------------- *)
(* A type of checksums.                                                      *)
(* ------------------------------------------------------------------------- *)

type checksum

(* ------------------------------------------------------------------------- *)
(* A total order.                                                            *)
(* ------------------------------------------------------------------------- *)

val compare : checksum * checksum -> order

val equal : checksum -> checksum -> bool

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val pp : checksum Print.pp

val toString : checksum -> string

(* ------------------------------------------------------------------------- *)
(* Parsing.                                                                  *)
(* ------------------------------------------------------------------------- *)

val parser : (char,checksum) Parse.parser

val fromString : string -> checksum

end
