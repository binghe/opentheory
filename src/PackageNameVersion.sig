(* ========================================================================= *)
(* PACKAGE NAME/VERSIONS                                                     *)
(* Copyright (c) 2009 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature PackageNameVersion =
sig

(* ------------------------------------------------------------------------- *)
(* A type of theory package name/versions.                                   *)
(* ------------------------------------------------------------------------- *)

type nameVersion

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

datatype nameVersion' =
    NameVersion' of
      {name : PackageName.name,
       version : PackageVersion.version};

val mk : nameVersion' -> nameVersion

val dest : nameVersion -> nameVersion'

val name : nameVersion -> PackageName.name

val version : nameVersion -> PackageVersion.version

(* ------------------------------------------------------------------------- *)
(* A total order.                                                            *)
(* ------------------------------------------------------------------------- *)

val compare : nameVersion * nameVersion -> order

val equal : nameVersion -> nameVersion -> bool

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val pp : nameVersion Print.pp

val toString : nameVersion -> string

(* ------------------------------------------------------------------------- *)
(* Parsing.                                                                  *)
(* ------------------------------------------------------------------------- *)

val parser : (char,nameVersion) Parse.parser

val fromString : string -> nameVersion

end
