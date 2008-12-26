(* ========================================================================= *)
(* ARTICLE SUMMARIES                                                         *)
(* Copyright (c) 2004-2008 Joe Hurd, distributed under the GNU GPL version 2 *)
(* ========================================================================= *)

signature Summary =
sig

(* ------------------------------------------------------------------------- *)
(* A type of article summary.                                                *)
(* ------------------------------------------------------------------------- *)

type summary

val fromThms : ThmSet.set -> summary

(* ------------------------------------------------------------------------- *)
(* Input/Output.                                                             *)
(* ------------------------------------------------------------------------- *)

val pp : summary Print.pp

val toTextFile : {summary : summary, filename : string} -> unit

end
