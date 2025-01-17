(* ========================================================================= *)
(* REPOSITORY CONFIG FILE                                                    *)
(* Copyright (c) 2010 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

structure RepositoryConfig :> RepositoryConfig =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* Constants.                                                                *)
(* ------------------------------------------------------------------------- *)

val authorSection = "author"
and autoCleanupKey = "auto"
and chmodSystemKey = "chmod"
and cleanupSection = "cleanup"
and cpSystemKey = "cp"
and curlSystemKey = "curl"
and echoSystemKey = "echo"
and emailAuthorKey = "email"
and installSection = "install"
and licenseSection = "license"
and minimalInstallKey = "minimal"
and nameAuthorKey = "name"
and nameLicenseKey = "name"
and nameRemoteKey = "name"
and refreshRemoteKey = "refresh"
and remoteSection = "repo"
and shaSystemKey = "sha"
and systemSection = "system"
and tarSystemKey = "tar"
and urlLicenseKey = "url"
and urlRemoteKey = "url";

(* Remote repository constants *)

val gilithRemoteName = PackageName.gilithRemote
and gilithRemoteUrl = "https://opentheory.gilith.com/";

val defaultRemoteRefresh = Time.fromSeconds 604800;  (* 1 week *)

val remoteDefaultRemoteRefresh = Time.fromSeconds 43200;  (* 12 hours *)

(* License constants *)

val licenseUrlDirectory = "https://www.gilith.com/opentheory/licenses";

val mitLicenseName = "MIT"
and mitLicenseUrl = licenseUrlDirectory ^ "/" ^ "MIT.txt";

val holLightLicenseName = "HOLLight"
and holLightLicenseUrl = licenseUrlDirectory ^ "/" ^ "HOLLight.txt";

(* Cleanup constants *)

val defaultCleanupAuto = SOME (Time.fromSeconds 3600);  (* 1 hour *)

val remoteDefaultCleanupAuto = (NONE : Time.time option);

(* Install constants *)

val defaultInstallMinimal = false;

val remoteDefaultInstallMinimal = true;

(* System constants *)

val defaultSystemChmod = "chmod"
and defaultSystemCp = "cp"
and defaultSystemCurl = "curl --silent --show-error --user-agent opentheory"
and defaultSystemEcho = "echo"
and defaultSystemSha = "shasum --binary"
and defaultSystemTar = "tar";

val remoteDefaultSystemChmod = defaultSystemChmod
and remoteDefaultSystemCp = defaultSystemCp
and remoteDefaultSystemCurl = defaultSystemCurl
and remoteDefaultSystemEcho = defaultSystemEcho
and remoteDefaultSystemSha = defaultSystemSha
and remoteDefaultSystemTar = defaultSystemTar;

(* ------------------------------------------------------------------------- *)
(* Time interval functions.                                                  *)
(* ------------------------------------------------------------------------- *)

fun toStringBool b = if b then "true" else "false";

fun fromStringBool s =
    if s = "true" then true
    else if s = "false" then false
    else raise Error ("bad boolean format: " ^ s);

fun toStringInterval t = Int.toString (Real.round (Time.toReal t));

fun fromStringInterval s =
    (case Int.fromString s of
       NONE => raise Error "not an integer"
     | SOME i =>
       if i >= 0 then Time.fromReal (Real.fromInt i)
       else raise Error "negative number")
    handle Error err => raise Error ("bad time interval format: " ^ err);

fun toStringOptionalInterval ot =
    case ot of
      SOME t => toStringInterval t
    | NONE => "never";

fun fromStringOptionalInterval s =
    if s = "never" then NONE
    else SOME (fromStringInterval s);

(* ------------------------------------------------------------------------- *)
(* A type of author configuration data.                                      *)
(* ------------------------------------------------------------------------- *)

fun toSectionAuthor author =
    let
      val PackageAuthor.Author' {name,email} = PackageAuthor.dest author
    in
      Config.Section
        {name = authorSection,
         keyValues =
           [Config.KeyValue
              {key = nameAuthorKey,
               value = name},
            Config.KeyValue
              {key = emailAuthorKey,
               value = email}]}
    end;

local
  datatype authorSectionState =
      AuthorSectionState of
        {name : string option,
         email : string option};

  val initialAuthorSectionState =
      let
        val name = NONE
        and email = NONE
      in
        AuthorSectionState
          {name = name,
           email = email}
      end;

  fun addNameAuthorSectionState x state =
      let
        val AuthorSectionState {name,email} = state

        val name =
            case name of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = nameAuthorKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        AuthorSectionState
          {name = name,
           email = email}
      end;

  fun addEmailAuthorSectionState x state =
      let
        val AuthorSectionState {name,email} = state

        val email =
            case email of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = emailAuthorKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        AuthorSectionState
          {name = name,
           email = email}
      end;

  fun processAuthorSectionState (kv,state) =
      let
        val Config.KeyValue {key,value} = kv
      in
        if key = nameAuthorKey then addNameAuthorSectionState value state
        else if key = emailAuthorKey then addEmailAuthorSectionState value state
        else
          let
            val mesg =
                "unknown key " ^ Config.toStringKey {key = key} ^
                " in section " ^
                Config.toStringSectionName {name = authorSection} ^
                " of config file"

            val () = warn mesg
          in
            state
          end
      end;

  fun finalAuthorSectionState state =
      let
        val AuthorSectionState {name,email} = state

        val name =
            case name of
              SOME x => x
            | NONE =>
              let
                val err =
                    "missing " ^
                    Config.toStringKey {key = nameAuthorKey} ^ " key"
              in
                raise Error err
              end

        val email =
            case email of
              SOME x => x
            | NONE =>
              let
                val err =
                    "missing " ^
                    Config.toStringKey {key = emailAuthorKey} ^ " key"
              in
                raise Error err
              end

        val auth' =
            PackageAuthor.Author'
              {name = name,
               email = email}
      in
        PackageAuthor.mk auth'
      end;
in
  fun fromSectionAuthor kvs =
      let
        val state = initialAuthorSectionState

        val state = List.foldl processAuthorSectionState state kvs
      in
        finalAuthorSectionState state
      end
      handle Error err =>
        let
          val err =
              "in section " ^
              Config.toStringSectionName {name = authorSection} ^
              " of config file:\n" ^ err
        in
          raise Error err
        end;
end;

val defaultAuthors : PackageAuthor.author list = [];

val remoteDefaultAuthors = defaultAuthors;

(* ------------------------------------------------------------------------- *)
(* A type of remote repository configuration data.                           *)
(* ------------------------------------------------------------------------- *)

datatype remote =
    Remote of
      {name : RepositoryRemote.name,
       url : string,
       refresh : Time.time};

fun nameRemote (Remote {name = x, ...}) = x;

fun urlRemote (Remote {url = x, ...}) = {url = x};

fun refreshRemote (Remote {refresh = x, ...}) = x;

fun findRemote remotes name =
    let
      fun pred remote = PackageName.equal name (nameRemote remote)
    in
      case List.filter pred remotes of
        [] => NONE
      | [remote] => SOME remote
      | _ :: _ :: _ => raise Bug "multiple repos with the same name"
    end;

fun memberRemote remotes name = Option.isSome (findRemote remotes name);

fun toSectionRemote remote =
    let
      val Remote {name,url,refresh} = remote
    in
      Config.Section
        {name = remoteSection,
         keyValues =
           [Config.KeyValue
              {key = nameRemoteKey,
               value = PackageName.toString name},
            Config.KeyValue
              {key = urlRemoteKey,
               value = url},
            Config.KeyValue
              {key = refreshRemoteKey,
               value = toStringInterval refresh}]}
    end;

local
  datatype remoteSectionState =
      RemoteSectionState of
        {name : string option,
         url : string option,
         refresh : string option};

  val initialRemoteSectionState =
      let
        val name = NONE
        and url = NONE
        and refresh = NONE
      in
        RemoteSectionState
          {name = name,
           url = url,
           refresh = refresh}
      end;

  fun addNameRemoteSectionState x state =
      let
        val RemoteSectionState {name,url,refresh} = state

        val name =
            case name of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = nameRemoteKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        RemoteSectionState
          {name = name,
           url = url,
           refresh = refresh}
      end;

  fun addUrlRemoteSectionState x state =
      let
        val RemoteSectionState {name,url,refresh} = state

        val url =
            case url of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = urlRemoteKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        RemoteSectionState
          {name = name,
           url = url,
           refresh = refresh}
      end;

  fun addRefreshRemoteSectionState x state =
      let
        val RemoteSectionState {name,url,refresh} = state

        val refresh =
            case refresh of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = refreshRemoteKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        RemoteSectionState
          {name = name,
           url = url,
           refresh = refresh}
      end;

  fun processRemoteSectionState (kv,state) =
      let
        val Config.KeyValue {key,value} = kv
      in
        if key = nameRemoteKey then addNameRemoteSectionState value state
        else if key = urlRemoteKey then addUrlRemoteSectionState value state
        else if key = refreshRemoteKey then addRefreshRemoteSectionState value state
        else
          let
            val mesg =
                "unknown key " ^ Config.toStringKey {key = key} ^
                " in section " ^
                Config.toStringSectionName {name = remoteSection} ^
                " of config file"

            val () = warn mesg
          in
            state
          end
      end;

  fun finalRemoteSectionState state =
      let
        val RemoteSectionState {name,url,refresh} = state

        val name =
            case name of
              SOME x => PackageName.fromString x
            | NONE =>
              let
                val err =
                    "missing " ^ Config.toStringKey {key = nameRemoteKey} ^ " key"
              in
                raise Error err
              end

        val url =
            case url of
              SOME x => x
            | NONE =>
              let
                val err =
                    "missing " ^ Config.toStringKey {key = urlRemoteKey} ^ " key"
              in
                raise Error err
              end

        val refresh =
            case refresh of
              SOME x => fromStringInterval x
            | NONE => defaultRemoteRefresh
      in
        Remote
          {name = name,
           url = url,
           refresh = refresh}
      end;
in
  fun fromSectionRemote kvs =
      let
        val state = initialRemoteSectionState

        val state = List.foldl processRemoteSectionState state kvs
      in
        finalRemoteSectionState state
      end
      handle Error err =>
        let
          val err =
              "in section " ^
              Config.toStringSectionName {name = remoteSection} ^
              " of config file:\n" ^ err
        in
          raise Error err
        end;
end;

val defaultRemote =
    Remote
      {name = gilithRemoteName,
       url = gilithRemoteUrl,
       refresh = defaultRemoteRefresh};

val remoteDefaultRemote =
    Remote
      {name = gilithRemoteName,
       url = gilithRemoteUrl,
       refresh = remoteDefaultRemoteRefresh};

val defaultRemotes = [defaultRemote];

val remoteDefaultRemotes = [remoteDefaultRemote];

(* ------------------------------------------------------------------------- *)
(* A type of license configuration data.                                     *)
(* ------------------------------------------------------------------------- *)

datatype license =
    License of
      {name : string,
       url : string};

fun nameLicense (License {name = x, ...}) = {name = x};

fun urlLicense (License {url = x, ...}) = {url = x};

fun findLicense licenses {name = n} =
    let
      fun pred license =
          let
            val {name = n'} = nameLicense license
          in
            n' = n
          end
    in
      case List.filter pred licenses of
        [] => NONE
      | [license] => SOME license
      | _ :: _ :: _ => raise Bug "multiple licenses with the same name"
    end;

fun memberLicense licenses name = Option.isSome (findLicense licenses name);

fun toSectionLicense license =
    let
      val License {name,url} = license
    in
      Config.Section
        {name = licenseSection,
         keyValues =
           [Config.KeyValue
              {key = nameLicenseKey,
               value = name},
            Config.KeyValue
              {key = urlLicenseKey,
               value = url}]}
    end;

local
  datatype licenseSectionState =
      LicenseSectionState of
        {name : string option,
         url : string option};

  val initialLicenseSectionState =
      let
        val name = NONE
        and url = NONE
      in
        LicenseSectionState
          {name = name,
           url = url}
      end;

  fun addNameLicenseSectionState x state =
      let
        val LicenseSectionState {name,url} = state

        val name =
            case name of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = nameLicenseKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        LicenseSectionState
          {name = name,
           url = url}
      end;

  fun addUrlLicenseSectionState x state =
      let
        val LicenseSectionState {name,url} = state

        val url =
            case url of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = urlLicenseKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        LicenseSectionState
          {name = name,
           url = url}
      end;

  fun processLicenseSectionState (kv,state) =
      let
        val Config.KeyValue {key,value} = kv
      in
        if key = nameLicenseKey then addNameLicenseSectionState value state
        else if key = urlLicenseKey then addUrlLicenseSectionState value state
        else
          let
            val mesg =
                "unknown key " ^ Config.toStringKey {key = key} ^
                " in section " ^
                Config.toStringSectionName {name = licenseSection} ^
                " of config file"

            val () = warn mesg
          in
            state
          end
      end;

  fun finalLicenseSectionState state =
      let
        val LicenseSectionState {name,url} = state

        val name =
            case name of
              SOME x => x
            | NONE =>
              let
                val err =
                    "missing " ^
                    Config.toStringKey {key = nameLicenseKey} ^ " key"
              in
                raise Error err
              end

        val url =
            case url of
              SOME x => x
            | NONE =>
              let
                val err =
                    "missing " ^
                    Config.toStringKey {key = urlLicenseKey} ^ " key"
              in
                raise Error err
              end
      in
        License
          {name = name,
           url = url}
      end;
in
  fun fromSectionLicense kvs =
      let
        val state = initialLicenseSectionState

        val state = List.foldl processLicenseSectionState state kvs
      in
        finalLicenseSectionState state
      end
      handle Error err =>
        let
          val err =
              "in section " ^
              Config.toStringSectionName {name = licenseSection} ^
              " of config file:\n" ^ err
        in
          raise Error err
        end;
end;

val mitLicense =
    License
      {name = mitLicenseName,
       url = mitLicenseUrl};

val holLightLicense =
    License
      {name = holLightLicenseName,
       url = holLightLicenseUrl};

val defaultLicenses =
    [mitLicense,
     holLightLicense];

val remoteDefaultLicenses = defaultLicenses;

(* ------------------------------------------------------------------------- *)
(* A type of cleanup configuration data.                                     *)
(* ------------------------------------------------------------------------- *)

datatype cleanup =
    Cleanup of
      {auto : Time.time option};

fun autoCleanup (Cleanup {auto = x, ...}) = x;

fun toSectionCleanup ins =
    let
      val Cleanup {auto} = ins
    in
      Config.Section
        {name = cleanupSection,
         keyValues =
           [Config.KeyValue
              {key = autoCleanupKey,
               value = toStringOptionalInterval auto}]}
    end;

local
  datatype cleanupSectionState =
      CleanupSectionState of
        {auto : string option};

  val initialCleanupSectionState =
      let
        val auto = NONE
      in
        CleanupSectionState
          {auto = auto}
      end;

  fun addAutoCleanupSectionState x state =
      let
        val CleanupSectionState {auto} = state

        val auto =
            case auto of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = autoCleanupKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        CleanupSectionState
          {auto = auto}
      end;

  fun processCleanupSectionState (kv,state) =
      let
        val Config.KeyValue {key,value} = kv
      in
        if key = autoCleanupKey then
          addAutoCleanupSectionState value state
        else
          let
            val mesg =
                "unknown key " ^ Config.toStringKey {key = key} ^
                " in section " ^
                Config.toStringSectionName {name = cleanupSection} ^
                " of config file"

            val () = warn mesg
          in
            state
          end
      end;

  fun finalCleanupSectionState ins state =
      let
        val CleanupSectionState {auto} = state

        val auto =
            case auto of
              SOME x => fromStringOptionalInterval x
            | NONE => autoCleanup ins
      in
        Cleanup
          {auto = auto}
      end;
in
  fun fromSectionCleanup sys kvs =
      let
        val state = initialCleanupSectionState

        val state = List.foldl processCleanupSectionState state kvs
      in
        finalCleanupSectionState sys state
      end
      handle Error err =>
        let
          val err =
              "in section " ^
              Config.toStringSectionName {name = cleanupSection} ^
              " of config file:\n" ^ err
        in
          raise Error err
        end;
end;

val defaultCleanup =
    Cleanup
      {auto = defaultCleanupAuto};

val remoteDefaultCleanup =
    Cleanup
      {auto = remoteDefaultCleanupAuto};

(* ------------------------------------------------------------------------- *)
(* A type of install configuration data.                                     *)
(* ------------------------------------------------------------------------- *)

datatype install =
    Install of
      {minimal : bool};

fun minimalInstall (Install {minimal = x, ...}) = x;

fun toSectionInstall ins =
    let
      val Install {minimal} = ins
    in
      Config.Section
        {name = installSection,
         keyValues =
           [Config.KeyValue
              {key = minimalInstallKey,
               value = toStringBool minimal}]}
    end;

local
  datatype installSectionState =
      InstallSectionState of
        {minimal : string option};

  val initialInstallSectionState =
      let
        val minimal = NONE
      in
        InstallSectionState
          {minimal = minimal}
      end;

  fun addMinimalInstallSectionState x state =
      let
        val InstallSectionState {minimal} = state

        val minimal =
            case minimal of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = minimalInstallKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        InstallSectionState
          {minimal = minimal}
      end;

  fun processInstallSectionState (kv,state) =
      let
        val Config.KeyValue {key,value} = kv
      in
        if key = minimalInstallKey then
          addMinimalInstallSectionState value state
        else
          let
            val mesg =
                "unknown key " ^ Config.toStringKey {key = key} ^
                " in section " ^
                Config.toStringSectionName {name = installSection} ^
                " of config file"

            val () = warn mesg
          in
            state
          end
      end;

  fun finalInstallSectionState ins state =
      let
        val InstallSectionState {minimal} = state

        val minimal =
            case minimal of
              SOME x => fromStringBool x
            | NONE => minimalInstall ins
      in
        Install
          {minimal = minimal}
      end;
in
  fun fromSectionInstall sys kvs =
      let
        val state = initialInstallSectionState

        val state = List.foldl processInstallSectionState state kvs
      in
        finalInstallSectionState sys state
      end
      handle Error err =>
        let
          val err =
              "in section " ^
              Config.toStringSectionName {name = installSection} ^
              " of config file:\n" ^ err
        in
          raise Error err
        end;
end;

val defaultInstall =
    Install
      {minimal = defaultInstallMinimal};

val remoteDefaultInstall =
    Install
      {minimal = remoteDefaultInstallMinimal};

(* ------------------------------------------------------------------------- *)
(* A type of system configuration data.                                      *)
(* ------------------------------------------------------------------------- *)

fun toSectionSystem sys =
    let
      val {chmod,cp,curl,echo,sha,tar} = RepositorySystem.dest sys
    in
      Config.Section
        {name = systemSection,
         keyValues =
           [Config.KeyValue
              {key = chmodSystemKey,
               value = chmod},
            Config.KeyValue
              {key = cpSystemKey,
               value = cp},
            Config.KeyValue
              {key = curlSystemKey,
               value = curl},
            Config.KeyValue
              {key = echoSystemKey,
               value = echo},
            Config.KeyValue
              {key = shaSystemKey,
               value = sha},
            Config.KeyValue
              {key = tarSystemKey,
               value = tar}]}
    end;

local
  datatype systemSectionState =
      SystemSectionState of
        {chmod : string option,
         cp : string option,
         curl : string option,
         echo : string option,
         sha : string option,
         tar : string option};

  val initialSystemSectionState =
      let
        val chmod = NONE
        and cp = NONE
        and curl = NONE
        and echo = NONE
        and sha = NONE
        and tar = NONE
      in
        SystemSectionState
          {chmod = chmod,
           cp = cp,
           curl = curl,
           echo = echo,
           sha = sha,
           tar = tar}
      end;

  fun addChmodSystemSectionState x state =
      let
        val SystemSectionState {chmod,cp,curl,echo,sha,tar} = state

        val chmod =
            case chmod of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = chmodSystemKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        SystemSectionState
          {chmod = chmod,
           cp = cp,
           curl = curl,
           echo = echo,
           sha = sha,
           tar = tar}
      end;

  fun addCpSystemSectionState x state =
      let
        val SystemSectionState {chmod,cp,curl,echo,sha,tar} = state

        val cp =
            case cp of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = cpSystemKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        SystemSectionState
          {chmod = chmod,
           cp = cp,
           curl = curl,
           echo = echo,
           sha = sha,
           tar = tar}
      end;

  fun addCurlSystemSectionState x state =
      let
        val SystemSectionState {chmod,cp,curl,echo,sha,tar} = state

        val curl =
            case curl of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = curlSystemKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        SystemSectionState
          {chmod = chmod,
           cp = cp,
           curl = curl,
           echo = echo,
           sha = sha,
           tar = tar}
      end;

  fun addEchoSystemSectionState x state =
      let
        val SystemSectionState {chmod,cp,curl,echo,sha,tar} = state

        val echo =
            case echo of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = echoSystemKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        SystemSectionState
          {chmod = chmod,
           cp = cp,
           curl = curl,
           echo = echo,
           sha = sha,
           tar = tar}
      end;

  fun addShaSystemSectionState x state =
      let
        val SystemSectionState {chmod,cp,curl,echo,sha,tar} = state

        val sha =
            case sha of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = shaSystemKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        SystemSectionState
          {chmod = chmod,
           cp = cp,
           curl = curl,
           echo = echo,
           sha = sha,
           tar = tar}
      end;

  fun addTarSystemSectionState x state =
      let
        val SystemSectionState {chmod,cp,curl,echo,sha,tar} = state

        val tar =
            case tar of
              NONE => SOME x
            | SOME x' =>
              let
                val err =
                    "multiple " ^
                    Config.toStringKey {key = tarSystemKey} ^
                    " keys: " ^ x ^ " and " ^ x'
              in
                raise Error err
              end
      in
        SystemSectionState
          {chmod = chmod,
           cp = cp,
           curl = curl,
           echo = echo,
           sha = sha,
           tar = tar}
      end;

  fun processSystemSectionState (kv,state) =
      let
        val Config.KeyValue {key,value} = kv
      in
        if key = chmodSystemKey then addChmodSystemSectionState value state
        else if key = cpSystemKey then addCpSystemSectionState value state
        else if key = curlSystemKey then addCurlSystemSectionState value state
        else if key = echoSystemKey then addEchoSystemSectionState value state
        else if key = shaSystemKey then addShaSystemSectionState value state
        else if key = tarSystemKey then addTarSystemSectionState value state
        else
          let
            val mesg =
                "unknown key " ^ Config.toStringKey {key = key} ^
                " in section " ^
                Config.toStringSectionName {name = systemSection} ^
                " of config file"

            val () = warn mesg
          in
            state
          end
      end;

  fun finalSystemSectionState sys state =
      let
        val SystemSectionState {chmod,cp,curl,echo,sha,tar} = state

        val chmod =
            case chmod of
              SOME x => x
            | NONE => let val {chmod = x} = RepositorySystem.chmod sys in x end

        val cp =
            case cp of
              SOME x => x
            | NONE => let val {cp = x} = RepositorySystem.cp sys in x end

        val curl =
            case curl of
              SOME x => x
            | NONE => let val {curl = x} = RepositorySystem.curl sys in x end

        val echo =
            case echo of
              SOME x => x
            | NONE => let val {echo = x} = RepositorySystem.echo sys in x end

        val sha =
            case sha of
              SOME x => x
            | NONE => let val {sha = x} = RepositorySystem.sha sys in x end

        val tar =
            case tar of
              SOME x => x
            | NONE => let val {tar = x} = RepositorySystem.tar sys in x end
      in
        RepositorySystem.mk
          {chmod = chmod,
           cp = cp,
           curl = curl,
           echo = echo,
           sha = sha,
           tar = tar}
      end;
in
  fun fromSectionSystem sys kvs =
      let
        val state = initialSystemSectionState

        val state = List.foldl processSystemSectionState state kvs
      in
        finalSystemSectionState sys state
      end
      handle Error err =>
        let
          val err =
              "in section " ^
              Config.toStringSectionName {name = systemSection} ^
              " of config file:\n" ^ err
        in
          raise Error err
        end;
end;

val defaultSystem =
    RepositorySystem.mk
      {chmod = defaultSystemChmod,
       cp = defaultSystemCp,
       curl = defaultSystemCurl,
       echo = defaultSystemEcho,
       sha = defaultSystemSha,
       tar = defaultSystemTar};

val remoteDefaultSystem =
    RepositorySystem.mk
      {chmod = remoteDefaultSystemChmod,
       cp = remoteDefaultSystemCp,
       curl = remoteDefaultSystemCurl,
       echo = remoteDefaultSystemEcho,
       sha = remoteDefaultSystemSha,
       tar = remoteDefaultSystemTar};

(* ------------------------------------------------------------------------- *)
(* A type of configuration data.                                             *)
(* ------------------------------------------------------------------------- *)

datatype config =
    Config of
      {authors : PackageAuthor.author list,
       remotes : remote list,
       licenses : license list,
       cleanup : cleanup,
       install : install,
       system : RepositorySystem.system};

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val empty =
    let
      val authors = []
      and remotes = []
      and licenses = []
      and cleanup = defaultCleanup
      and install = defaultInstall
      and system = defaultSystem
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

fun authors (Config {authors = x, ...}) = x;

fun remotes (Config {remotes = x, ...}) = x;

fun licenses (Config {licenses = x, ...}) = x;

fun cleanup (Config {cleanup = x, ...}) = x;

fun install (Config {install = x, ...}) = x;

fun system (Config {system = x, ...}) = x;

(* ------------------------------------------------------------------------- *)
(* Basic operations.                                                         *)
(* ------------------------------------------------------------------------- *)

fun addAuthor cfg auth =
    let
      val Config
            {authors,
             remotes,
             licenses,
             cleanup,
             install,
             system} = cfg

      val () =
          if not (List.exists (PackageAuthor.equal auth) authors) then ()
          else
            let
              val err =
                  "repeated author " ^ PackageAuthor.toString auth ^
                  " in the config file"
            in
              raise Error err
            end

      val authors = authors @ [auth]
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

fun addRemote cfg remote =
    let
      val Config
            {authors,
             remotes,
             licenses,
             cleanup,
             install,
             system} = cfg

      val () =
          let
            val name = nameRemote remote
          in
            if not (memberRemote remotes name) then ()
            else
              let
                val err =
                    "multiple repos named " ^ PackageName.toString name ^
                    " in the config file"
              in
                raise Error err
              end
          end

      val remotes = remotes @ [remote]
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

fun addLicense cfg license =
    let
      val Config
            {authors,
             remotes,
             licenses,
             cleanup,
             install,
             system} = cfg

      val () =
          let
            val name as {name = n} = nameLicense license
          in
            if not (memberLicense licenses name) then ()
            else
              let
                val err =
                    "multiple licenses named " ^ n ^
                    " in the config file"
              in
                raise Error err
              end
          end

      val licenses = licenses @ [license]
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

fun replaceCleanup cfg cleanup =
    let
      val Config
            {authors,
             remotes,
             licenses,
             cleanup = _,
             install,
             system} = cfg
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

fun replaceInstall cfg install =
    let
      val Config
            {authors,
             remotes,
             licenses,
             cleanup,
             install = _,
             system} = cfg
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

fun replaceSystem cfg system =
    let
      val Config
            {authors,
             remotes,
             licenses,
             cleanup,
             install,
             system = _} = cfg
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

(* ------------------------------------------------------------------------- *)
(* Pretty-printing.                                                          *)
(* ------------------------------------------------------------------------- *)

fun toSections cfg =
    let
      val Config
            {authors,
             remotes,
             licenses,
             cleanup,
             install,
             system} = cfg

      val sections =
          List.map toSectionAuthor authors @
          List.map toSectionRemote remotes @
          List.map toSectionLicense licenses @
          [toSectionCleanup cleanup] @
          [toSectionInstall install] @
          [toSectionSystem system]
    in
      Config.Config {sections = sections}
    end;

val pp = Print.ppMap toSections Config.pp;

(* ------------------------------------------------------------------------- *)
(* I/O.                                                                      *)
(* ------------------------------------------------------------------------- *)

local
  fun addSection (sect,cfg) =
      let
        val Config.Section {name,keyValues} = sect
      in
        if name = authorSection then
          let
            val auth = fromSectionAuthor keyValues
          in
            addAuthor cfg auth
          end
        else if name = remoteSection then
          let
            val remote = fromSectionRemote keyValues
          in
            addRemote cfg remote
          end
        else if name = licenseSection then
          let
            val license = fromSectionLicense keyValues
          in
            addLicense cfg license
          end
        else if name = cleanupSection then
          let
            val cln = cleanup cfg

            val cln = fromSectionCleanup cln keyValues
          in
            replaceCleanup cfg cln
          end
        else if name = installSection then
          let
            val ins = install cfg

            val ins = fromSectionInstall ins keyValues
          in
            replaceInstall cfg ins
          end
        else if name = systemSection then
          let
            val sys = system cfg

            val sys = fromSectionSystem sys keyValues
          in
            replaceSystem cfg sys
          end
        else
          let
            val mesg =
                "unknown config section: " ^
                Config.toStringSectionName {name = name}

            val () = warn mesg
          in
            cfg
          end
      end;

  fun fromSections cfg =
      let
        val Config.Config {sections} = cfg
      in
        List.foldl addSection empty sections
      end;
in
  fun fromTextFile filename =
      let
        val cfg =
            Config.fromTextFile filename
            handle IO.Io _ => Config.empty
      in
        fromSections cfg
      end
(*OpenTheoryDebug
      handle Error err => raise Bug ("RepositoryConfig.fromTextFile: " ^ err);
*)
end;

fun toTextFile {config,filename} =
    let
      val s = Print.toStream pp config
    in
      Stream.toTextFile {filename = filename} s
    end;

(* ------------------------------------------------------------------------- *)
(* Default configurations.                                                   *)
(* ------------------------------------------------------------------------- *)

val default =
    let
      val authors = defaultAuthors
      and remotes = defaultRemotes
      and licenses = defaultLicenses
      and cleanup = defaultCleanup
      and install = defaultInstall
      and system = defaultSystem
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

val remoteDefault =
    let
      val authors = remoteDefaultAuthors
      and remotes = remoteDefaultRemotes
      and licenses = remoteDefaultLicenses
      and cleanup = remoteDefaultCleanup
      and install = remoteDefaultInstall
      and system = remoteDefaultSystem
    in
      Config
        {authors = authors,
         remotes = remotes,
         licenses = licenses,
         cleanup = cleanup,
         install = install,
         system = system}
    end;

end
