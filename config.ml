open BatteriesExceptionless

(* TODO all categories global? Std, Analyses, Experimental, Debugging *)
type std = {
  outfile         : string       [@default ""] [@doc "File to print output to."];
  includes        : string list  [@default []];
  kernel_includes : string list;
  custom_includes : string list;
  (* ... *)
  justcil         : bool         [@default false];
  (* ... *)
} [@@doc "Standard options"] [@@deriving yojson, create]
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

exception Config of string
let fail msg = raise (Config msg)

let default = create ()
(* print only values different from default *)
let print_diff = print_endline % Yojson.Safe.to_string % to_yojson
(* print all values *)
let print_all _ = failwith "TODO"
let print = print_diff
let parse_res = of_yojson % Yojson.Safe.from_string
let parse s = match parse_res s with
  | `Ok x -> x
  | `Error x -> fail @@ "parsing error: " ^ x

let phase = ref 0 (* the current phase *)
let config : t option ref = ref None (* the current config (overwrite after parsing arguments? alternative would be to carry it around) *)
let set_config s = config := Some (parse s)
let get_config () = Option.get_exn !config (Config "not parsed yet")
let get_phase () =
  let x = get_config () in
  match List.at x.phases !phase with
  | `Ok x -> x
  | `Invalid_argument x -> fail @@ "phase index out of bounds: " ^ x

(* tests: parse from string and print again *)
let t1 = "{\"global\":{\"std\":{\"kernel_includes\":[],\"custom_includes\":[],\"justcil\":true}}, \"phases\": [{\"activated\": [[\"Ana2\"]]}]}"
let t2 = "{foo: null}" (* if strict then fail else ignore *)
(* let _ = parse t1 |> print *)
(* let _ = parse t2 |> print *)
