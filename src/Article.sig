(* ========================================================================= *)
(* ARTICLES OF PROOFS IN HIGHER ORDER LOGIC                                  *)
(* Copyright (c) 2004-2008 Joe Hurd, distributed under the GNU GPL version 2 *)
(* ========================================================================= *)

signature Article =
sig

(* ------------------------------------------------------------------------- *)
(* Articles                                                                  *)
(* ------------------------------------------------------------------------- *)

type article

val search : article -> Sequent.sequent -> Thm.thm option

val saved : article -> Thm.thm list

(* ------------------------------------------------------------------------- *)
(* I/O                                                                       *)
(* ------------------------------------------------------------------------- *)

val fromTextFile :
    {filename : string, interpretation : Interpretation.interpretation} ->
    article

val toTextFile : {filename : string, article : article} -> unit

end
