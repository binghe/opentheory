(* ========================================================================= *)
(* THEORY PACKAGES                                                           *)
(* Copyright (c) 2010 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

signature Package =
sig

(* ------------------------------------------------------------------------- *)
(* A type of theory packages.                                                *)
(* ------------------------------------------------------------------------- *)

type package

(* ------------------------------------------------------------------------- *)
(* Constructor.                                                              *)
(* ------------------------------------------------------------------------- *)

val mk :
    {system : RepositorySystem.system,
     nameVersion : PackageNameVersion.nameVersion,
     checksum : Checksum.checksum option,
     directory : string} -> package

(* ------------------------------------------------------------------------- *)
(* Package directory.                                                        *)
(* ------------------------------------------------------------------------- *)

val directory : package -> {directory : string}

val joinDirectory : package -> {filename : string} -> {filename : string}

val existsDirectory : package -> bool

val createDirectory : package -> unit

val nukeDirectory : package -> unit

(* ------------------------------------------------------------------------- *)
(* Is the package installed?                                                 *)
(* ------------------------------------------------------------------------- *)

val isInstalled : package -> bool

(* ------------------------------------------------------------------------- *)
(* Package information.                                                      *)
(* ------------------------------------------------------------------------- *)

val information : package -> PackageInformation.information

(* ------------------------------------------------------------------------- *)
(* Package name and version.                                                 *)
(* ------------------------------------------------------------------------- *)

val name : package -> PackageName.name

val version : package -> PackageVersion.version

val nameVersion : package -> PackageNameVersion.nameVersion

(* ------------------------------------------------------------------------- *)
(* Package description.                                                      *)
(* ------------------------------------------------------------------------- *)

val description : package -> {description : string}

(* ------------------------------------------------------------------------- *)
(* Package author.                                                           *)
(* ------------------------------------------------------------------------- *)

val author : package -> PackageAuthor.author

(* ------------------------------------------------------------------------- *)
(* Package license.                                                          *)
(* ------------------------------------------------------------------------- *)

val license : package -> {license : string}

(* ------------------------------------------------------------------------- *)
(* Package requirements.                                                     *)
(* ------------------------------------------------------------------------- *)

val requires : package -> PackageName.name list

(* ------------------------------------------------------------------------- *)
(* The files needed by the package.                                          *)
(* ------------------------------------------------------------------------- *)

val theoryFile : package -> {filename : string}

val articleFiles : package -> {filename : string} list

val interpretationFiles : package -> {filename : string} list

val extraFiles : package -> PackageExtra.extra list

val allFiles : package -> {filename : string} list

(* ------------------------------------------------------------------------- *)
(* Package dependencies.                                                     *)
(* ------------------------------------------------------------------------- *)

val includes :
    package ->
    (PackageNameVersion.nameVersion * Checksum.checksum option) list

val nameVersionIncludes : package -> PackageNameVersionSet.set

(* ------------------------------------------------------------------------- *)
(* Show.                                                                     *)
(* ------------------------------------------------------------------------- *)

val show : package -> Show.show

(* ------------------------------------------------------------------------- *)
(* Package theory graph.                                                     *)
(* ------------------------------------------------------------------------- *)

val theories : package -> PackageTheory.theory list

val emptyTheories : package -> bool

(* ------------------------------------------------------------------------- *)
(* Package tarball.                                                          *)
(* ------------------------------------------------------------------------- *)

val tarballFile : package -> {filename : string}

val tarball : package -> PackageTarball.tarball

val packTarball : package -> unit

val copyTarball : package -> PackageTarball.tarball -> unit

val downloadTarball : package -> {url : string} -> unit

val checksum : package -> Checksum.checksum

val unpackTarball : package -> {minimal : bool} -> unit

val upload : package -> {url : string, token : string} -> {response : string}

(* ------------------------------------------------------------------------- *)
(* Package theorems.                                                         *)
(* ------------------------------------------------------------------------- *)

val theoremsFile : package -> {filename : string}

val theorems : package -> PackageTheorems.theorems

val writeTheorems : package -> PackageTheorems.theorems -> unit

(* ------------------------------------------------------------------------- *)
(* Package document.                                                         *)
(* ------------------------------------------------------------------------- *)

val documentFile : package -> {filename : string}

val writeDocument : package -> PackageDocument.document -> unit

end
