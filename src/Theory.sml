(* ========================================================================= *)
(* THEORIES OF HIGHER ORDER LOGIC                                            *)
(* Copyright (c) 2009 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

structure Theory :> Theory =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* A type of theory syntax.                                                  *)
(* ------------------------------------------------------------------------- *)

datatype 'a theory =
    Local of 'a theory * 'a theory
  | Sequence of 'a theory list
  | Article of {filename : string}
  | Interpret of Interpretation.interpretation * 'a theory
  | Import of 'a;

val empty = Sequence [];

fun append th1 th2 = Sequence [th1,th2];

(* ------------------------------------------------------------------------- *)
(* Executing theories.                                                       *)
(* ------------------------------------------------------------------------- *)

fun toArticle info =
    let
      val {savable,
           simulations,
           importToArticle,
           interpretation = initialInt,
           import,
           directory,
           theory = initialThy} = info

      fun compile known int thy =
          case thy of
            Local (thy1,thy2) =>
            let
              val known = compileAppend known int (thy1,known)
            in
              compile known int thy2
            end
          | Sequence thys =>
            List.foldl (compileAppend known int) Article.empty thys
          | Article {filename} =>
            let
              val filename = directory ^ "/" ^ filename
            in
              Article.fromTextFile
                {savable = savable,
                 known = known,
                 simulations = simulations,
                 interpretation = int,
                 filename = filename}
            end
          | Interpret (pint,pthy) =>
            let
              val int = Interpretation.compose pint int
            in
              compile known int pthy
            end
          | Import imp =>
            importToArticle imp

      and compileAppend known int (thy,art) =
          Article.append art (compile known int thy)

      val known = Article.concat (map importToArticle import)
    in
      compile known initialInt initialThy
    end;

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

fun ppBlock ppX x =
    Print.blockProgram Print.Consistent 0
      [Print.blockProgram Print.Consistent 2
         [Print.addString "{",
          Print.addBreak 1,
          ppX x],
       Print.addBreak 1,
       Print.addString "}"];

fun pp ppImp =
    let
      fun ppThy thy =
          case thy of
            Local (thy1,thy2) =>
            Print.blockProgram Print.Consistent 0
              [Print.addString "local ",
               ppThy thy1,
               Print.addString " in",
               ppSpaceThy thy2]
          | Sequence thys =>
            ppBlock ppList thys
          | Article {filename} =>
            Print.blockProgram Print.Consistent 2
              [Print.addString "article",
               Print.addBreak 1,
               Print.addString "\"",
               Print.addString filename,
               Print.addString "\";"]
          | Interpret (int,thy) =>
            Print.blockProgram Print.Consistent 0
              [Print.addString "interpret ",
               ppBlock Interpretation.pp int,
               Print.addString " in",
               ppSpaceThy thy]
          | Import imp =>
            Print.blockProgram Print.Consistent 2
              [Print.addString "import",
               Print.addBreak 1,
               ppImp imp,
               Print.addString ";"]

      and ppSpaceThy thy = Print.sequence (Print.addBreak 1) (ppThy thy)

      and ppList thys =
          case thys of
            [] => Print.skip
          | thy :: thys => Print.program (ppThy thy :: map ppSpaceThy thys)
    in
      ppThy
    end;

(* ------------------------------------------------------------------------- *)
(* Parsing.                                                                  *)
(* ------------------------------------------------------------------------- *)

local
  infixr 9 >>++
  infixr 8 ++
  infixr 7 >>
  infixr 6 ||

  open Parse;

  val articleKeywordParser = exactString "article"
  and closeBlockParser = exactString "}"
  and importKeywordParser = exactString "import"
  and inKeywordParser = exactString "in"
  and interpretKeywordParser = exactString "interpret"
  and localKeywordParser = exactString "local"
  and openBlockParser = exactString "{"
  and quoteParser = exactString "\""
  and terminatorParser = exactString ";";

  val quotedFilenameParser =
      let
        fun isFilenameChar c = c <> #"\n" andalso c <> #"\""

        val filenameParser = atLeastOne (some isFilenameChar)
      in
        (quoteParser ++ filenameParser ++ quoteParser) >>
        (fn ((),(f,())) => {filename = implode f})
      end;

  fun theoryParser impParser inp =
      (localParser impParser ||
       sequenceParser impParser ||
       articleParser ||
       interpretParser impParser ||
       importParser impParser) inp

  and localParser impParser inp =
      ((localKeywordParser ++ atLeastOneSpace ++
        theoryParser impParser ++ manySpace ++
        inKeywordParser ++ atLeastOneSpace ++
        theoryParser impParser) >>
       (fn ((),((),(t1,((),((),((),t2)))))) => Local (t1,t2))) inp

  and sequenceParser impParser inp =
      ((openBlockParser ++ manySpace ++
        many (theorySpaceParser impParser) ++
        closeBlockParser) >>
       (fn ((),((),(ts,()))) => Sequence ts)) inp

  and articleParser inp =
      ((articleKeywordParser ++ manySpace ++
        quotedFilenameParser ++ manySpace ++ terminatorParser) >>
       (fn ((),((),(f,((),())))) => Article f)) inp

  and interpretParser impParser inp =
      ((interpretKeywordParser ++ manySpace ++
        openBlockParser ++ manySpace ++
        Interpretation.parser ++ manySpace ++
        closeBlockParser ++
        inKeywordParser ++ atLeastOneSpace ++
        theoryParser impParser) >>
       (fn ((),((),((),((),(i,((),((),((),((),t))))))))) => Interpret (i,t))) inp

  and importParser impParser inp =
      ((importKeywordParser ++ atLeastOneSpace ++
        impParser ++ manySpace ++ terminatorParser) >>
       (fn ((),((),(i,((),())))) => Import i)) inp

  and theorySpaceParser impParser inp =
      (theoryParser impParser ++ manySpace >> fst) inp;
in
  fun parser impParser = manySpace ++ theorySpaceParser impParser >> snd;
end;

end
