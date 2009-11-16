(* ========================================================================= *)
(* HIGHER ORDER LOGIC THEORY GRAPHS                                          *)
(* Copyright (c) 2009 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature Graph =
sig

(* ------------------------------------------------------------------------- *)
(* A type of theory graphs.                                                  *)
(* ------------------------------------------------------------------------- *)

type graph

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val empty : graph

val instances : graph -> InstanceSet.set

val member : Instance.instance -> graph -> bool

(* ------------------------------------------------------------------------- *)
(* Adding instances.                                                         *)
(* ------------------------------------------------------------------------- *)

val add : graph -> Instance.instance -> graph

(* ------------------------------------------------------------------------- *)
(* Looking up theory instances by package name.                              *)
(* ------------------------------------------------------------------------- *)

val lookup : graph -> PackageName.name -> InstanceSet.set

(* ------------------------------------------------------------------------- *)
(* Finding matching theory instances.                                        *)
(* ------------------------------------------------------------------------- *)

val match :
    graph ->
    {savable : bool,
     requiresAtLeast : InstanceSet.set,
     interpretationEquivalentTo : Interpretation.interpretation,
     package : PackageName.name} ->
    InstanceSet.set

(* ------------------------------------------------------------------------- *)
(* Importing theory packages.                                                *)
(* ------------------------------------------------------------------------- *)

val importTheory :
    graph ->
    {savable : bool,
     requires : InstanceSet.set,
     simulations : Simulation.simulations,
     importToInstance : PackageRequire.name -> Instance.instance,
     interpretation : Interpretation.interpretation,
     package : PackageName.name option,
     directory : string,
     theory : PackageTheory.theory} ->
    graph * Instance.instance

val matchImportPackageName :
    graph ->
    {finder : PackageFinder.finder,
     savable : bool,
     simulations : Simulation.simulations,
     requiresAtLeast : InstanceSet.set,
     interpretationEquivalentTo : Interpretation.interpretation,
     package : PackageName.name} ->
    graph * Instance.instance

val importPackageName :
    graph ->
    {finder : PackageFinder.finder,
     savable : bool,
     simulations : Simulation.simulations,
     requires : InstanceSet.set,
     interpretation : Interpretation.interpretation,
     package : PackageName.name} ->
    graph * Instance.instance

val importPackage :
    graph ->
    {finder : PackageFinder.finder,
     savable : bool,
     simulations : Simulation.simulations,
     requires : InstanceSet.set,
     interpretation : Interpretation.interpretation,
     package : Package.package} ->
    graph * Instance.instance

val importContents :
    graph ->
    {finder : PackageFinder.finder,
     savable : bool,
     simulations : Simulation.simulations,
     requires : InstanceSet.set,
     interpretation : Interpretation.interpretation,
     package : PackageName.name option,
     directory : string,
     contents : PackageContents.contents} ->
    graph * Instance.instance

val importRequire :
    graph ->
    {finder : PackageFinder.finder,
     savable : bool,
     simulations : Simulation.simulations,
     requires : InstanceSet.set,
     interpretation : Interpretation.interpretation,
     requireNameToInstance : PackageRequire.name -> Instance.instance,
     require : PackageRequire.require} ->
    graph * Instance.instance

end
