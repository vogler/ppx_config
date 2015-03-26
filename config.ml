open BatteriesExceptionless

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
type t = {
  phases : phase list [@default [create_phase ()]];
  global : global [@default create_global ()]
} [@@deriving yojson {strict = true}, create]

let default = create ()
(* print only values different from default *)
let print_diff = print_endline % Yojson.Safe.to_string % to_yojson
(* print all values *)
let print_all _ = failwith "TODO"
let print = print_diff
let parse_res = of_yojson % Yojson.Safe.from_string
let parse s = match parse_res s with
  | `Ok x -> x
  | `Error x -> failwith @@ "Config parsing error: " ^ x

(* tests: parse from string and print again *)
let t1 = "{\"global\":{\"std\":{\"kernel_includes\":[],\"custom_includes\":[],\"justcil\":true}}, \"phases\": [{\"activated\": [[\"Ana2\"]]}]}"
let t2 = "{foo: null}" (* if strict then fail else ignore *)
(* let _ = parse t1 |> print *)
(* let _ = parse t2 |> print *)
