## Problems

- [to_yojson ?(omit_defaults=true)](https://github.com/whitequark/ppx_deriving_yojson/issues/19)

- [@@deriving yojson {strict = false}]: strict should be an optional argument to of_yojson instead (warn about  fields not in the record, but be backwards-compatible by ignoring new options

- [Implicit vs. explicit defaults give different output](https://github.com/whitequark/ppx_deriving_yojson/issues/20)

        type t = {
          outfile         : string option;
          includes        : string list  [@default []];
          kernel_includes : string list;
          (* ... *)
        } [@@deriving yojson, create]
        let r = create ()
        (* let r = { r with outfile = Some "bar" } *)
        let _ = print_endline @@ Yojson.Safe.to_string @@ to_yojson @@ r

- Updating fields is ugly, but that shouldn't be a problem, since we only read them or use the generated parsers.

        let r = { r with global = { r.global with std = { init.global.std with justcil = true } } }
