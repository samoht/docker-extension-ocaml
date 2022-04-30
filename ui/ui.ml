open Brr

let dd = Dd.v ()

let get_id id =
  match Document.find_el_by_id G.document (Jstr.v id) with
  | None ->
      Console.(debug [ str (Printf.sprintf "element %S not found" id) ]);
      raise Not_found
  | Some elt -> elt

let call_hello k =
  let vm = Dd.vm_service dd in
  let response = Dd.get vm "/hello" in
  Fut.await response k

let main () =
  (* Set-up the page structure *)
  let root = get_id "root" in
  let button = El.button [ El.txt' "Call backend" ] in
  let pre = El.pre [ El.txt' "[..]" ] in
  El.set_children root [ button; pre ];

  (* Add onClick events *)
  let update_pre x = El.set_children pre [ El.txt' x ] in
  Ev.listen Ev.click (fun _ -> call_hello update_pre) (El.as_target button)

let () = main ()
