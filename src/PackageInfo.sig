(* ========================================================================= *)
(* THEORY PACKAGE META-DATA                                                  *)
(* Copyright (c) 2010 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature PackageInfo =
sig

(* ------------------------------------------------------------------------- *)
(* Package directory name.                                                   *)
(* ------------------------------------------------------------------------- *)

val packageDirectory : PackageName.name -> {directory : string}

(* ------------------------------------------------------------------------- *)
(* Tarball filenames.                                                        *)
(* ------------------------------------------------------------------------- *)

val destTarball : {filename : string} -> PackageName.name option

val isTarball : {filename : string} -> bool

(* ------------------------------------------------------------------------- *)
(* A type of theory package meta-data.                                       *)
(* ------------------------------------------------------------------------- *)

type info

val mk : {name : PackageName.name, directory : string} -> info

val name : info -> PackageName.name

val base : info -> PackageBase.base

val version : info -> PackageVersion.version

val directory : info -> {directory : string}

(* ------------------------------------------------------------------------- *)
(* Package directory operations.                                             *)
(* ------------------------------------------------------------------------- *)

val joinDirectory : info -> {filename : string} -> {filename : string}

val existsDirectory : info -> bool

val createDirectory : info -> unit

val nukeDirectory : info -> unit

(* ------------------------------------------------------------------------- *)
(* Is the package installed?                                                 *)
(* ------------------------------------------------------------------------- *)

val isInstalled : info -> bool

(* ------------------------------------------------------------------------- *)
(* The files needed by the package.                                          *)
(* ------------------------------------------------------------------------- *)

val theoryFile : info -> {filename : string}

val articles : info -> {filename : string} list

val extraFiles : info -> {name : string, filename : string} list

val allFiles : info -> {filename : string} list

(* ------------------------------------------------------------------------- *)
(* Read the package.                                                         *)
(* ------------------------------------------------------------------------- *)

val package : info -> Package.package

(* ------------------------------------------------------------------------- *)
(* Package tarball.                                                          *)
(* ------------------------------------------------------------------------- *)

val tarball : info -> {filename : string}

val createTarball : info -> unit

val createChecksum : info -> unit

val parserChecksum : (char, {checksum : string}) Parse.parser

val readChecksum : info -> {checksum : string}

(* ------------------------------------------------------------------------- *)
(* Package dependencies.                                                     *)
(* ------------------------------------------------------------------------- *)

val packages : info -> PackageNameSet.set

end
