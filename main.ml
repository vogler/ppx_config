open BatteriesExceptionless

(* open all analyses modules so that they can extend Analyses.ana (we do this for all modules in goblint.ml anyway) *)
open Ana1
open Ana2

let _ =
  print_string "default config: ";
  Config.(print default);
  print_endline @@ "phase.global.std.outfile = " ^ Config.((get_phase ()).global.std.outfile)
