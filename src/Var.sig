(* ========================================================================= *)
(* HIGHER ORDER LOGIC VARIABLES                                              *)
(* Copyright (c) 2004-2006 Joe Hurd, distributed under the GNU GPL version 2 *)
(* ========================================================================= *)

signature Var =
sig

(* ------------------------------------------------------------------------- *)
(* A type of higher order logic term variables.                              *)
(* ------------------------------------------------------------------------- *)

datatype var = Var of Name.name * Type.ty

(* ------------------------------------------------------------------------- *)
(* The name of a variable.                                                   *)
(* ------------------------------------------------------------------------- *)

val name : var -> Name.name

(* ------------------------------------------------------------------------- *)
(* The type of a variable.                                                   *)
(* ------------------------------------------------------------------------- *)

val typeOf : var -> Type.ty

(* ------------------------------------------------------------------------- *)
(* A total order.                                                            *)
(* ------------------------------------------------------------------------- *)

val compare : var * var -> order

val equal : var -> var -> bool

(* ------------------------------------------------------------------------- *)
(* Type variables.                                                           *)
(* ------------------------------------------------------------------------- *)

val addSharingTypeVars : Type.sharingTypeVars -> var -> Type.sharingTypeVars

val typeVars : var -> NameSet.set

(* ------------------------------------------------------------------------- *)
(* Type operators.                                                           *)
(* ------------------------------------------------------------------------- *)

val addSharingTypeOps : Type.sharingTypeOps -> var -> Type.sharingTypeOps

val typeOps : var -> NameSet.set

(* ------------------------------------------------------------------------- *)
(* Fresh variables.                                                          *)
(* ------------------------------------------------------------------------- *)

val renameAvoiding : NameSet.set -> var -> var

(* ------------------------------------------------------------------------- *)
(* Type substitutions.                                                       *)
(* ------------------------------------------------------------------------- *)

val sharingSubst : var -> TypeSubst.subst -> var option * TypeSubst.subst

val subst : TypeSubst.subst -> var -> var option

end
