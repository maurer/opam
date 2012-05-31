(***********************************************************************)
(*                                                                     *)
(*    Copyright 2012 OCamlPro                                          *)
(*    Copyright 2012 INRIA                                             *)
(*                                                                     *)
(*  All rights reserved.  This file is distributed under the terms of  *)
(*  the GNU Public License version 3.0.                                *)
(*                                                                     *)
(*  TypeRex is distributed in the hope that it will be useful,         *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of     *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      *)
(*  GNU General Public License for more details.                       *)
(*                                                                     *)
(***********************************************************************)

open Types
open Utils

let log fmt = Globals.log "PATH" fmt

let available dir =
  let files = Filename.list dir in
  let files = List.filter (fun f -> Filename.check_suffix f ".opam") files in
  List.fold_left (fun set file ->
    match NV.of_filename file with
    | None    ->
        log "%s is not a valid package filename!" (Filename.to_string file);
        set
    | Some nv -> NV.Set.add nv set
  ) NV.Set.empty files

let compiler_list dir =
  if Dirname.exists dir then (
    let files = Filename.list dir in
    let files = List.filter (fun f -> Filename.check_suffix f ".comp") files in
    let l =
      List.map
        (Filename.chop_extension
         |> Filename.basename
         |> Basename.to_string
         |> OCaml_V.of_string)
        files in
    OCaml_V.Set.of_list l
  ) else
    OCaml_V.Set.empty

let versions nvset =
  NV.Set.fold (fun nv vset -> V.Set.add (NV.version nv) vset) nvset V.Set.empty

module G = struct

  type t = dirname (* [$opam/] *)

  let create () = Dirname.of_string !Globals.root_path

  let root opam = opam

  let dirname_of_nv nv = Dirname.of_string (NV.to_string nv)

  let config t = t // "config"

  let opam_dir t = t / "opam"

  let aliases t = t // "aliases"

  let opam t nv = opam_dir t // (NV.to_string nv ^ ".opam")

  let compiler_dir t = t / "compilers"

  let compiler t ov = compiler_dir t // (OCaml_V.to_string ov ^ ".comp")

  let compiler_list t = compiler_list (compiler_dir t)

  let available t = available (opam_dir t)

  let available_versions t n =
    versions (NV.Set.filter (fun nv -> NV.name nv = n) (available t))
    
  let descr_dir t = t / "descr"

  let descr t nv = descr_dir t // NV.to_string nv

  let archive_dir t = t / "archives"

  let archive t nv = archive_dir t // (NV.to_string nv ^ ".tar.gz")

  let repo_index t = t / "repo" // "index"

end

module C = struct

  type t = dirname (* [$opam/$oversion/ *)

  let create oversion =
    Dirname.of_string !Globals.root_path / Alias.to_string oversion

  let root x = x

  let lib_dir t = t / "lib"

  let lib t n = lib_dir t / N.to_string n

  let stublibs t = lib_dir t / "stublibs"

  let doc_dir t = t / "doc"

  let doc t n = doc_dir t / N.to_string n

  let bin t = t / "bin"

  let installed t = t // "installed"

  let build_dir t = t / "build"

  let build t nv = build_dir t / NV.to_string nv

  let build_ocaml t = build_dir t / "_"

  let build_install t nv = build t nv // (N.to_string (NV.name nv) ^ ".install")

  let build_config t nv = build t nv // (N.to_string (NV.name nv) ^ ".config")

  let install_dir t = t / "install"

  let install t n = install_dir t // (N.to_string n ^ ".install")

  let reinstall t = t // "reinstall"

  let config_dir t = t / "config"

  let config t n = config_dir t // (N.to_string n ^ ".config")

end


module R = struct

  type t = dirname (* [$opam/repo/$repo/] *)

  let create r =
    Dirname.of_string !Globals.root_path / "repo" / Repository.name r

  let of_path path = path
    
  let root t = t

  let config t = t // "config"

  let opam_dir t = t / "opam"

  let available t = available (opam_dir t)

  let available_versions t n =
    versions (NV.Set.filter (fun nv -> NV.name nv = n) (available t))

  let opam t nv = opam_dir t // (NV.to_string nv ^ ".opam")

  let descr_dir t = t / "descr"

  let descr t nv = descr_dir t // (NV.to_string nv)

  let archive_dir t = t / "archives"

  let archive t nv = archive_dir t // (NV.to_string nv ^ ".tar.gz")

  let updated t = t // "updated"

  let upload t = t / "upload"

  let upload_opam_dir t = upload t / "opam"

  let upload_descr_dir t = upload t / "descr"

  let upload_archives_dir t = upload t / "archives"

  let upload_opam t nv = upload_opam_dir t // (NV.to_string nv ^ ".opam")

  let upload_descr t nv = upload_descr_dir t // NV.to_string nv

  let upload_archives t nv = upload_archives_dir t // (NV.to_string nv ^ ".tar.gz")

  let compiler_dir t = t / "compilers"

  let compiler t ov = compiler_dir t // (OCaml_V.to_string ov ^ ".comp")

  let compiler_list t = compiler_list (compiler_dir t)

end
