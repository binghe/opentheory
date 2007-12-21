(* ========================================================================= *)
(* HIGHER ORDER LOGIC SEQUENTS                                               *)
(* Copyright (c) 2004-2006 Joe Hurd, distributed under the GNU GPL version 2 *)
(* ========================================================================= *)

structure Sequent :> Sequent =
struct

open Useful

structure Ty = Type;
structure T = Term;
structure TAS = TermAlphaSet;

(* ------------------------------------------------------------------------- *)
(* Sequents                                                                  *)
(* ------------------------------------------------------------------------- *)

type sequent = {hyp : TAS.set, concl : T.term};

(* ------------------------------------------------------------------------- *)
(* Checking the hypotheses and conclusion are of type bool                   *)
(* ------------------------------------------------------------------------- *)

fun boolean {hyp,concl} =
    Ty.equal (T.typeOf concl) Ty.boolTy andalso
    TAS.all (fn h => Ty.equal (T.typeOf h) Ty.boolTy) hyp;

(* ------------------------------------------------------------------------- *)
(* A total order on sequents modulo alpha equivalence                        *)
(* ------------------------------------------------------------------------- *)

fun compare ({hyp = h1, concl = c1}, {hyp = h2, concl = c2}) =
    prodCompare T.alphaCompare TAS.compare ((c1,h1),(c2,h2));

fun equal s1 s2 = compare (s1,s2) = EQUAL;

end

structure SequentOrdered =
struct type t = Sequent.sequent val compare = Sequent.compare end

structure SequentSet =
ElementSet (SequentOrdered)

structure SequentMap =
KeyMap (SequentOrdered)
