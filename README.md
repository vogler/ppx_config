## Motivation/current situation

Options, their default value and description are currently defined in `defaults.ml`:

    type category = Std             (** Parsing input, includes, standard stuff, etc. *)
    | Analyses        (** Analyses                                      *)
    | Experimental    (** Experimental features of analyses             *)
    | Debugging       (** Debugging, tracing, etc.                      *)

    let _ = ()
          ; reg Std "outfile"         ""             "File to print output to."
          ; reg Std "includes"        "[]"           "List of directories to include."
          ...

Additionally there is some weird schema string:

    let default_schema = "\
    { 'id'              : 'root'
    , 'type'            : 'object'
    , 'required'        : ['outfile', ...]
    , 'additionalProps' : false
    , 'properties' :
      { 'ana' :
        { 'type'            : 'object'
        , 'additionalProps' : true
        , 'required'        : []
        }
      , ...

What are `additionalProps` and `required` (since everything has a default...)?

Options are read from a json file via `--conf file` or set with `--set, --sets, --enable, --disable` according to the path:

    path' ::== \epsilon              (*  *)
           | . <field-name> path'  (* field access *)
           | [ <index-nr> ] path'  (* array index access *)
           | [ + ] path'           (* cons to array *)
           | [ * ] path'           (* reset array *)

    path ::==              path'     (*  *)
          | <field_name> path'     (* you can leave out the first dot *)

Options are accessed like this in the code:

    ... get_bool "exp.privatization" ...
    let my_favorite_things = List.map Json.string (get_list "exp.precious_globs") in

## Plan

- No outward facing changes: command line options, help, path semantics unchanged
- Safety: options should be immutable -> get rid of `GobConfig.set_*`
- Safety: replace path strings in code with record fields and use type generated parsing and printing functions
    - no more exceptions `PathParseError, ConfTypeError` for wrong path-strings in the code
    - autocompletion for options
    - no more need for type-specific stuff `{get,set}_{int,bool,string,list,null}`
    - no more custom json code (`json.ml, jsonLexer.mll, jsonParser.mly, jsonSchema.ml`)
- maybe (at the end) bundle everything together as [ppx_deriving_cmdliner](https://github.com/whitequark/ppx_deriving/issues/19) with json option handling

Example from above:

    let old = List.map Json.string (get_list "exp.precious_globs") in
    let new = !config.exp.precious_globs in

## What already works

- `[@@deriving create]` with `[@default "..."]` for creating records with default values
- `[@@deriving yojson]` for parsing/printing functions `of_yojson`, `to_yojson`

## Still missing

- deriving fieldnames for listing of available options (see [fieldslib](https://github.com/janestreet/fieldslib) (only camlp4), [ppx_deriving](https://github.com/whitequark/ppx_deriving#plugin-create))
    - field names would be derived by record, so if a field is also a record, its fieldnames should look like this: `parent_field.child_field`
    - example:

            type x = { a : int; b : int } [@@deriving fields]
            type y = { c : x; d : int } [@@deriving fields]
            val x_fields : string list = ["a"; "b"]
            val y_fields : string list = ["c.a"; "c.b"; "d"]

- introduce something like `[@doc "..."]` for the description of each option
- maybe also generate something like `t_fields_annot`:

        type x = { a : int [@default 0] [@doc "a value"] } [@@deriving fields {annot = true}]
        val x_fields : string list = ["a"]
        val x_fields_annot : (string * ([> `Default | `Doc] * string) list) list = ["a", [`Default,"0"; `Doc,"a value"]]

    Above, we try to generate a string from the payload of each annotation (since we don't have heterogeneous lists). Problems:

    1. `show` might not always be sensible/easy -> alternative would be to just collect annotations that have a string payload...
    2. we then have this ugly list we have to match on, even for annotations exist for every field

    So, it would be better to have a tuple or record (problem with non-unique fieldnames) of annotations, and some way to specify mandatory ones (which should lead to a warning if missing):

        type x = { a : int [@default 0] [@doc "a value"] [@foo "bar"] } [@@deriving fields {annot = true; mandatory = [`Default; `Doc]}]
        val x_fields : string list = ["a"]
        val x_fields_annot : (string * string * string * ([> `Foo of string]) list) list = ["a", "0", "a value", [`Foo "bar"]]

## Other problems

- [to_yojson ?(omit_defaults=true)](https://github.com/whitequark/ppx_deriving_yojson/issues/19)

- [@@deriving yojson {strict = false}]: strict should be an optional argument to of_yojson instead (warn about  fields not in the record, but be backwards-compatible by ignoring new options

- [Implicit vs. explicit defaults give different output](https://github.com/whitequark/ppx_deriving_yojson/issues/20) which currently requires to specify a default everywhere.

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
