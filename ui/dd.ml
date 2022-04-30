open Fut.Syntax

type service = Jv.t
type t = Jv.t

let get t url =
  let+ result =
    Fut.of_promise ~ok:Jv.to_string (Jv.call t "get" [| Jv.of_string url |])
  in
  Result.get_ok result

let v () = Jv.get Jv.global "ddClient"
let extension t = Jv.get t "extension"
let vm t = Jv.get t "vm"
let service t = Jv.get t "service"
let vm_service t = t |> extension |> vm |> service
