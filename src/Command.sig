(* ========================================================================= *)
(* OPENTHEORY COMMANDS                                                       *)
(* Copyright (c) 2004 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature Command =
sig

(* ------------------------------------------------------------------------- *)
(* A type of commands.                                                       *)
(* ------------------------------------------------------------------------- *)

datatype command =
    Num of int
  | Name of Name.name
  | Error
  | Nil
  | Cons
  | TypeVar
  | TypeOp
  | Var
  | Const
  | App
  | Abs
  | Thm
  | Call
  | Return
  | Def
  | Ref
  | Remove
  | Pop
  | Save

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val pp : command Print.pp

val toString : command -> string

(* ------------------------------------------------------------------------- *)
(* Parsing.                                                                  *)
(* ------------------------------------------------------------------------- *)

val parser : (char,command) Parse.parser

val spacedParser : (char, command list) Parse.parser

end
