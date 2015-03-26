open BatteriesExceptionless
open Ana2 (* if the module is not used here, we need to open it, otherwise Analyses.ana won't be extended and parsing the constructor will fail *)

(* docs:
extensible variant types: http://caml.inria.fr/pub/docs/manual-ocaml/extn.html#sec246
*)

(* TODO all categories global? Std, Analyses, Experimental, Debugging *)
type std = {
  outfile         : string       [@default ""];
  includes        : string list  [@default []];
  kernel_includes : string list;
  custom_includes : string list;
  (* ... *)
  justcil         : bool         [@default false];
  (* ... *)
} [@@deriving yojson, create]
type ana = {
  path_sens  : Analyses.ana list [@default [Ana1.default]];
  ctx_insens : Analyses.ana list [@default [Ana1.default]];
  warnings   : bool [@default false];
  (* ... *)
} [@@deriving yojson, create]
type global = {
  std : std [@default create_std ()];
  ana : ana [@default create_ana ()];
} [@@deriving yojson, create]

type phase = {
  activated : Analyses.ana list [@default [Ana1.default]];
  global : global [@default create_global ()];
} [@@deriving yojson, create]
type t = { phases : phase list [@default [create_phase ()]]; global : global [@default create_global ()] } [@@deriving yojson {strict = false}, create]

let print x = print_endline @@ Yojson.Safe.to_string @@ to_yojson x

(* create with defaults and print *)
let r = create ()
(* modify and print (only values different from defaults). NB: includes vs. kernel_includes: empty lists get output if default is not explicitly set to []. *)
(* let r = { r with global = { r.global with std = { init.global.std with justcil = true } } } *)
let _ = print r

(* parse from string and print again *)
let s = "{\"global\":{\"std\":{\"kernel_includes\":[],\"custom_includes\":[],\"justcil\":true}}, \"phases\": [{\"activated\": [[\"Ana2\"]]}]}"
(* let s = "{foo: null}" *)
let j = Yojson.Safe.from_string s
let r = match of_yojson j with `Ok x -> x | `Error x -> failwith x
(* let r = { r with global = { r.global with std = { r.global.std with justcil = true } } } *)
let _ = print @@ r
(* print all values (even if equal to default) *)
