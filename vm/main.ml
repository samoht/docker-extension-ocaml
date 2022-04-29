let usage_msg = "main [--socket <path>]"
let socket_path = ref "/run/guest/volumes-service.sock"

let hello =
  Dream.router [ (Dream.get "/hello" @@ fun _request -> Dream.json "hello") ]

let () =
  Arg.parse
    [
      ( "-socket",
        String (fun x -> socket_path := x),
        "Unix domain socket to listen on" );
    ]
    (fun _ -> ())
    usage_msg;
  Sys.remove !socket_path;
  Dream.log "Starting listening on %s\n" !socket_path;
  Dream.run ~socket_path:!socket_path hello
