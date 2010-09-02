(* ========================================================================= *)
(* PACKAGE DIRECTORY CHECKSUMS                                               *)
(* Copyright (c) 2010 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature DirectoryChecksums =
sig

(* ------------------------------------------------------------------------- *)
(* Checksums filenames.                                                      *)
(* ------------------------------------------------------------------------- *)

val mkFilename : string -> {filename : string}

(* ------------------------------------------------------------------------- *)
(* A type of package directory checkums.                                     *)
(* ------------------------------------------------------------------------- *)

type checksums

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val mk : {filename : string} -> checksums

val filename : checksums -> {filename : string}

(* ------------------------------------------------------------------------- *)
(* Creating a new package checksums file.                                    *)
(* ------------------------------------------------------------------------- *)

val create : DirectoryConfig.system -> {filename : string} -> unit

(* ------------------------------------------------------------------------- *)
(* Looking up packages.                                                      *)
(* ------------------------------------------------------------------------- *)

val peek : checksums -> PackageName.name -> Checksum.checksum option

val member : PackageName.name -> checksums -> bool

(* ------------------------------------------------------------------------- *)
(* Adding a new package.                                                     *)
(* ------------------------------------------------------------------------- *)

val add :
    DirectoryConfig.system ->
    checksums -> PackageName.name * Checksum.checksum -> unit

(* ------------------------------------------------------------------------- *)
(* Deleting a package.                                                       *)
(* ------------------------------------------------------------------------- *)

val delete : checksums -> PackageName.name -> unit

(* ------------------------------------------------------------------------- *)
(* Updating the package list.                                                *)
(* ------------------------------------------------------------------------- *)

val update : DirectoryConfig.system -> checksums -> {url : string} -> unit

end
