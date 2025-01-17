(* ========================================================================= *)
(* THEORY GRAPHS                                                             *)
(* Copyright (c) 2009 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

structure TheoryGraph :> TheoryGraph =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* Ancestor theories.                                                        *)
(* ------------------------------------------------------------------------- *)

fun parents thy = TheorySet.fromList (Theory.imports thy);

local
  fun ancsThy acc thy thys =
      if TheorySet.member thy acc then ancsList acc thys
      else ancsPar (TheorySet.add acc thy) thy thys

  and ancsPar acc thy thys =
      ancsList acc (Theory.imports thy @ thys)

  and ancsList acc thys =
      case thys of
        [] => acc
      | thy :: thys => ancsThy acc thy thys;
in
  fun ancestors thy = ancsPar TheorySet.empty thy [];
end;

(* ------------------------------------------------------------------------- *)
(* Primitive theory packages cannot be replaced with their contents.         *)
(* ------------------------------------------------------------------------- *)

local
  fun primsNested acc (Theory.Nested thys) = List.foldl primsNameThy acc thys

  and primsNameThy ((_,thy),acc) = primsThy acc thy

  and primsThy acc thy =
      if Theory.isPrimitive thy then TheorySet.add acc thy
      else primsNode acc (Theory.node thy)

  and primsNode acc node =
      case node of
        Theory.Article _ => raise Bug "TheoryGraph.primitives: Article"
      | Theory.Package {nested,...} => primsNested acc nested
      | Theory.Union => acc;
in
  val addPrimitives = primsThy;
end;

fun primitives thy =
    let
(*OpenTheoryDebug
      val _ = not (Theory.isUnion thy) orelse
              raise Bug "TheoryGraph.primitives: Union"
*)
    in
      addPrimitives TheorySet.empty thy
    end;

local
  datatype vps = VPS of TheorySet.set * Theory.theory list;

  fun primsList seen acc thys = List.foldl primsThy (seen,acc) thys

  and primsThy (thy,(seen,acc)) =
      if TheorySet.member thy seen then (seen,acc)
      else
        let
          val seen = TheorySet.add seen thy
        in
          if Theory.isPrimitive thy then (seen, thy :: acc)
          else primsThy' seen acc (Theory.dest thy)
        end

  and primsThy' seen acc thy' =
      let
        val Theory.Theory' {imports,node,...} = thy'
      in
        case node of
          Theory.Article _ => raise Bug "TheoryGraph.visiblePrimitives: Article"
        | Theory.Package {nested,...} =>
          let
            val main = Theory.mainNested nested
          in
            primsThy (main,(seen,acc))
          end
        | Theory.Union => primsList seen acc imports
      end;
in
  val initialVisiblePrimitives = VPS (TheorySet.empty,[]);

  fun addVisiblePrimitives (VPS seen_acc) thy = VPS (primsThy (thy,seen_acc));

  fun finalizeVisiblePrimitives (VPS (_,acc)) = List.rev acc;
end;

fun visiblePrimitives thy =
    let
(*OpenTheoryDebug
      val _ = not (Theory.isUnion thy) orelse
              raise Bug "TheoryGraph.visiblePrimitives: Union"
*)
      val vps = initialVisiblePrimitives

      val vps = addVisiblePrimitives vps thy
    in
      finalizeVisiblePrimitives vps
    end;

(* ------------------------------------------------------------------------- *)
(* Expand Union theories before searching for primitives.                    *)
(* ------------------------------------------------------------------------- *)

local
  fun expand (thy,acc) =
      if not (Theory.isUnion thy) then addPrimitives acc thy
      else List.foldl expand acc (Theory.imports thy);
in
  fun expandUnionPrimitives thy = expand (thy,TheorySet.empty);
end;

local
  fun expand (thy,vps) =
      if not (Theory.isUnion thy) then addVisiblePrimitives vps thy
      else List.foldl expand vps (Theory.imports thy);
in
  fun expandUnionVisiblePrimitives thy =
      let
        val vps = initialVisiblePrimitives

        val vps = expand (thy,vps)
      in
        finalizeVisiblePrimitives vps
      end;
end;

(* ------------------------------------------------------------------------- *)
(* Theory summaries.                                                         *)
(* ------------------------------------------------------------------------- *)

datatype summary = Summary of Summary.summary TheoryMap.map;

val emptySummary = Summary (TheoryMap.new ());

fun addSummary (thy, Summary m) =
    let
      val sum = Theory.summary thy
    in
      Summary (TheoryMap.insert m (thy,sum))
    end;

val mkSummary = TheorySet.foldl addSummary emptySummary;

fun peekSummary (Summary m) thy = TheoryMap.peek m thy;

fun getSummary sums thy =
    case peekSummary sums thy of
      SOME sum => sum
    | NONE => raise Bug "TheoryGraph.getSummary";

fun getRequires req thy =
    case TheoryMap.peek req thy of
      SOME seqs => seqs
    | NONE => raise Bug "TheoryGraph.getRequires";

fun getListRequires req thys =
    if List.null thys then SequentMap.new ()
    else
      let
        val seqsl = List.map (getRequires req) thys
      in
        SequentMap.unionListDomain (List.rev seqsl)
      end;

fun addRequires sums (thy,req) =
    if TheoryMap.inDomain thy req then req
    else
      let
        val imps = Theory.imports thy

        val (seqs,req) =
            case peekSummary sums thy of
              SOME sum =>
              let
                fun addSeq (seq,seqs) =
                    if SequentMap.inDomain seq seqs then seqs
                    else SequentMap.insert seqs (seq,thy)

                val req = List.foldl (addRequires sums) req imps

                val seqs = getListRequires req imps

                val reqs = Sequents.sequents (Summary.requires sum)

                val seqs = SequentSet.foldl addSeq seqs reqs
              in
                (seqs,req)
              end
            | NONE =>
              case Theory.node thy of
                Theory.Article _ =>
                let
                  val seqs = SequentMap.new ()
                in
                  (seqs,req)
                end
              | Theory.Package {nested,...} =>
                let
                  val main = Theory.mainNested nested

                  val req = addRequires sums (main,req)

                  val seqs = getRequires req main
                in
                  (seqs,req)
                end
              | Theory.Union =>
                let
                  val req = List.foldl (addRequires sums) req imps

                  val seqs = getListRequires req imps
                in
                  (seqs,req)
                end
      in
        TheoryMap.insert req (thy,seqs)
      end;

fun mkRequires sums thy =
    let
      val req = TheoryMap.new ()

      val req = addRequires sums (thy,req)

      val seqs = getRequires req thy
    in
      SequentMap.mapPartial (Theory.destPackage o snd) seqs
    end;

fun addProvides sums (thy,acc) =
    let
      fun add (seq,acc) = SequentMap.insert acc (seq,thy)

      val seqs = Sequents.sequents (Summary.provides (getSummary sums thy))
    in
      SequentSet.foldl add acc seqs
    end;

fun mkProvides sums thy =
    let
      val acc = SequentMap.new ()

      val prims = expandUnionVisiblePrimitives thy

      val acc = List.foldl (addProvides sums) acc (List.rev prims)
    in
      SequentMap.mapPartial (Theory.destPackage o snd) acc
    end;

fun summary thy =
    let
      val sums = mkSummary (expandUnionPrimitives thy)

      val sum = Theory.summary thy

      val req = mkRequires sums thy

      val prov = mkProvides sums thy

      val sum' =
          PackageSummary.Summary'
            {summary = sum,
             requires = req,
             provides = prov}
    in
      PackageSummary.mk sum'
    end;

(* ------------------------------------------------------------------------- *)
(* Theory environments.                                                      *)
(* ------------------------------------------------------------------------- *)

datatype environment =
    Environment of
      {named : Theory.theory PackageNameMap.map,
       imported : (PackageTheory.name * Theory.theory) list};

val emptyEnvironment =
    let
      val named = PackageNameMap.new ()
      and imported = []
    in
      Environment
        {named = named,
         imported = imported}
    end;

fun peekEnvironment (Environment {named,...}) name =
    PackageNameMap.peek named name;

fun insertEnvironment env (name,thy) =
    let
      val Environment {named,imported} = env

      val () =
          if not (PackageNameMap.inDomain name named) then ()
          else raise Error ("duplicate theory name: " ^
                            PackageName.toString name)

      val named = PackageNameMap.insert named (name,thy)

      val imported = (name,thy) :: imported
    in
      Environment
        {named = named,
         imported = imported}
    end;

fun nestedEnvironment (Environment {imported,...}) =
    Theory.Nested (List.rev imported);

fun mainEnvironment (Environment {named,...}) =
    case PackageNameMap.peek named PackageTheory.mainName of
      SOME thy => thy
    | NONE => raise Error "no main theory";

(* ------------------------------------------------------------------------- *)
(* A type of theory graphs.                                                  *)
(* ------------------------------------------------------------------------- *)

datatype graph =
    Graph of
      {savable : bool,
       theories : TheorySet.set,
       packages : TheorySet.set PackageNameVersionMap.map};

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

fun empty {savable} =
    let
      val theories = TheorySet.empty

      val packages = PackageNameVersionMap.new ()
    in
      Graph
        {savable = savable,
         theories = theories,
         packages = packages}
    end;

fun savable (Graph {savable = x, ...}) = x;

fun theories (Graph {theories = x, ...}) = x;

fun member thy graph = TheorySet.member thy (theories graph);

(* ------------------------------------------------------------------------- *)
(* Looking up theories by package name.                                      *)
(* ------------------------------------------------------------------------- *)

fun lookupPackages pkgs namever =
    case PackageNameVersionMap.peek pkgs namever of
      SOME thys => thys
    | NONE => TheorySet.empty;

fun lookup (Graph {packages,...}) = lookupPackages packages;

(* ------------------------------------------------------------------------- *)
(* Adding theories.                                                          *)
(* ------------------------------------------------------------------------- *)

fun add graph thy =
    let
(*OpenTheoryDebug
      val thys = parents thy

      val _ = TheorySet.all (fn i => member i graph) thys orelse
              raise Bug "TheoryGraph.add: parent theory not in graph"
*)

      val Graph {savable,theories,packages} = graph

(*OpenTheoryDebug
      val sav = Article.savable (Theory.article thy)

      val _ = sav orelse not savable orelse
              raise Bug "TheoryGraph.add: adding unsavable theory to savable graph"
*)

      val theories = TheorySet.add theories thy

      val packages =
          case Theory.destPackage thy of
            NONE => packages
          | SOME p =>
            let
              val s = lookupPackages packages p

              val s = TheorySet.add s thy
            in
              PackageNameVersionMap.insert packages (p,s)
            end
    in
      Graph
        {savable = savable,
         theories = theories,
         packages = packages}
    end;

(* ------------------------------------------------------------------------- *)
(* Finding matching theories.                                                *)
(* ------------------------------------------------------------------------- *)

datatype specification =
    Specification of
      {imports : TheorySet.set,
       interpretation : Interpretation.interpretation,
       nameVersion : PackageNameVersion.nameVersion,
       checksum : Checksum.checksum option}

fun match graph spec =
    let
      val Specification
            {imports = imp,
             interpretation = int,
             nameVersion = namever,
             checksum = chk} = spec

      val matchChk =
          case chk of
            NONE => K true
          | SOME chk =>
            fn thy =>
               case Theory.node thy of
                 Theory.Package {checksum = chk', ...} =>
                 (case chk' of
                    SOME chk' => Checksum.equal chk' chk
                  | NONE => true)
               | _ => raise Bug "TheoryGraph.match.matchChk"

      fun matchImp thy =
          let
            val imp' = TheorySet.fromList (Theory.imports thy)
          in
            TheorySet.equal imp imp'
          end

      fun matchInt thy =
          let
            val int' = Theory.interpretation thy
          in
            Interpretation.equal int int'
          end

      fun matchThy thy =
          matchChk thy andalso
          matchImp thy andalso
          matchInt thy
    in
      TheorySet.filter matchThy (lookup graph namever)
    end;

(* ------------------------------------------------------------------------- *)
(* Importing theory packages.                                                *)
(* ------------------------------------------------------------------------- *)

fun importNode finder graph info =
    let
      val {directory,imports,interpretation,nodeImports,node} = info
    in
      case node of
          PackageTheory.Article {interpretation = int, filename = f} =>
          let
            val imports = TheorySet.union imports nodeImports

            val filename = OS.Path.concat (directory,f)

            val node = Theory.Article {filename = f}

            val interpretation =
                let
                  val realint =
                      PackageInterpretation.realize {directory = directory} int
                in
                  Interpretation.compose realint interpretation
                end

            val article =
                Article.fromTextFile
                  {savable = savable graph,
                   import = TheorySet.article imports,
                   interpretation = interpretation,
                   filename = filename}

            val imports = TheorySet.toList imports

            val thy' =
                Theory.Theory'
                  {imports = imports,
                   interpretation = interpretation,
                   node = node,
                   article = article}

            val thy = Theory.mk thy'

            val graph = add graph thy
          in
            (graph,thy)
          end
        | PackageTheory.Include
            {interpretation = int,
             package = namever,
             checksum = chk} =>
          let
            val imports = TheorySet.union imports nodeImports

            val interpretation =
                let
                  val realint =
                      PackageInterpretation.realize {directory = directory} int
                in
                  Interpretation.compose realint interpretation
                end

            val spec =
                Specification
                  {imports = imports,
                   interpretation = interpretation,
                   nameVersion = namever,
                   checksum = chk}
          in
            import finder graph spec
          end
        | PackageTheory.Union =>
          let
            val imports = TheorySet.toList nodeImports

            val node = Theory.Union

            val article = TheorySet.article nodeImports

            val thy' =
                Theory.Theory'
                  {imports = imports,
                   interpretation = interpretation,
                   node = node,
                   article = article}

            val thy = Theory.mk thy'

            val graph = add graph thy
          in
            (graph,thy)
          end
    end

and importTheory finder graph env info =
    let
      val {directory,imports,interpretation,theory} = info

      val PackageTheory.Theory {name, imports = imps, node} = theory

      fun addImp (imp,acc) =
          case peekEnvironment env imp of
            SOME thy => TheorySet.add acc thy
          | NONE =>
            let
              val err = "unknown theory import: " ^ PackageName.toString imp
            in
              raise Error err
            end

      val nodeImports =
          List.foldl addImp TheorySet.empty (PackageTheory.imports theory)

      val info =
          {directory = directory,
           imports = imports,
           interpretation = interpretation,
           nodeImports = nodeImports,
           node = node}

      val (graph,thy) = importNode finder graph info

      val env = insertEnvironment env (name,thy)
    in
      (graph,env,thy)
    end

and importTheories finder graph info =
    let
      val {directory,imports,interpretation,theories} = info

      fun impThy (theory,(graph,env)) =
          let
            val info =
                {directory = directory,
                 imports = imports,
                 interpretation = interpretation,
                 theory = theory}

            val (graph,env,_) = importTheory finder graph env info
          in
            (graph,env)
          end

      val env = emptyEnvironment
    in
      List.foldl impThy (graph,env) theories
    end

and importPackageInformation finder graph data =
    let
      val {directory,
           imports,
           interpretation,
           nameVersion = namever,
           checksum = chk,
           information = info} = data

      val theories = PackageInformation.theories info

      val data =
          {directory = directory,
           imports = imports,
           interpretation = interpretation,
           theories = theories}

      val (graph,env) = importTheories finder graph data

      val node =
          Theory.Package
            {package = namever,
             checksum = chk,
             nested = nestedEnvironment env}

      val article = Theory.article (mainEnvironment env)

      val article = Article.unionList [article]  (* zero inference profile *)

      val imports = TheorySet.toList imports

      val thy' =
          Theory.Theory'
            {imports = imports,
             interpretation = interpretation,
             node = node,
             article = article}

      val thy = Theory.mk thy'

      val graph = add graph thy
    in
      (graph,thy)
    end

and importPackage finder graph data =
    let
      val {imports,interpretation,package} = data

      val {directory} = Package.directory package
      and namever = Package.nameVersion package
      and chk = Package.checksum package
      and info = Package.information package

      val data =
          {directory = directory,
           imports = imports,
           interpretation = interpretation,
           nameVersion = namever,
           checksum = SOME chk,
           information = info}
    in
      importPackageInformation finder graph data
    end

and import finder graph spec =
    let
      val thys = match graph spec
    in
      if not (TheorySet.null thys) then (graph, TheorySet.pick thys)
      else
        let
          val Specification
                {imports,
                 interpretation,
                 nameVersion = namever,
                 checksum = chk} = spec

          val pkg = PackageFinder.get finder namever chk

          val data =
              {imports = imports,
               interpretation = interpretation,
               package = pkg}
        in
          importPackage finder graph data
          handle Error err =>
            raise Error ("while importing package " ^
                         PackageNameVersion.toString namever ^ "\n" ^ err)
        end
    end;

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

fun pp graph =
    Print.consistentBlock 0
      [Print.ppString "Graph{",
       Print.ppInt (TheorySet.size (theories graph)),
       Print.ppString "}"];

end
