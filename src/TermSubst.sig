(* ========================================================================= *)
(* SUBSTITUTIONS FOR HIGHER ORDER LOGIC TERMS                                *)
(* Copyright (c) 2004-2006 Joe Hurd, distributed under the GNU GPL version 2 *)
(* ========================================================================= *)

signature TermSubst =
sig

(* ------------------------------------------------------------------------- *)
(* Term substitution maps.                                                   *)
(* ------------------------------------------------------------------------- *)

type termSubstMap = Term.term VarMap.map

val emptyTermMap : termSubstMap

val nullTermMap : termSubstMap -> bool

val singletonTermMap : Var.var * Term.term -> termSubstMap

val fromListTermMap : (Var.var * Term.term) list -> termSubstMap

(* ------------------------------------------------------------------------- *)
(* Type and term substitution maps.                                          *)
(* ------------------------------------------------------------------------- *)

type substMap = TypeSubst.substMap * termSubstMap

val emptyMap : substMap

(* ------------------------------------------------------------------------- *)
(* Capture-avoiding substitutions of type and term variables.                *)
(* ------------------------------------------------------------------------- *)

type subst

val empty : subst

val null : subst -> bool

val mk : substMap -> subst

(* ------------------------------------------------------------------------- *)
(* Applying substitutions: returns NONE for unchanged.                       *)
(* ------------------------------------------------------------------------- *)

val sharingSubstType : Type.ty -> subst -> Type.ty option * subst

val substType : subst -> Type.ty -> Type.ty option

val sharingSubst : Term.term -> subst -> Term.term option * subst

val subst : subst -> Term.term -> Term.term option

end
