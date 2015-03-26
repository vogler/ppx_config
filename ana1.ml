type options = { widen : bool [@default false] } [@@deriving yojson, create]
type Analyses.ana += Ana1 of options [@@deriving yojson]
let default = Ana1 (create_options ())
