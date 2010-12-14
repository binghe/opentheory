(* ========================================================================= *)
(* HIGHER ORDER LOGIC CONSTANTS                                              *)
(* Copyright (c) 2009 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature Const =
sig

(* ------------------------------------------------------------------------- *)
(* A type of constants.                                                      *)
(* ------------------------------------------------------------------------- *)

type const = TypeTerm.const

type constData =
     {name : Name.name,
      prov : TypeTerm.provConst}

val mk : constData -> const

val dest : const -> constData

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val name : const -> Name.name

val prov : const -> TypeTerm.provConst

val mkUndef : Name.name -> const

val isUndef : const -> bool

(* ------------------------------------------------------------------------- *)
(* A total order.                                                            *)
(* ------------------------------------------------------------------------- *)

val compare : const * const -> order

val equal : const -> const -> bool

(* ------------------------------------------------------------------------- *)
(* Reconstructing the type from the provenance.                              *)
(* ------------------------------------------------------------------------- *)

val typeOf : const -> Type.ty option

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val ppWithShow : Show.show -> const Print.pp

val pp : const Print.pp

val toString : const -> string

val toHtml : (const * Type.ty option) * Name.name -> Html.inline

end
