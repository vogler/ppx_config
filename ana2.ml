(* type Analyses.ana += Ana2 = Analyses.Ana2 [@@deriving yojson] (* why doesn't this work when the doc says it would? *) *)
type Analyses.ana += Ana2 [@@deriving yojson]
let default = Ana2
