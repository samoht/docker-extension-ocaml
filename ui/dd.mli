(** Docker Desktop client API *)

type t
(** The type for clients to the Docker Desktop API. *)

val v : unit -> t
(** [v ()] is an handler to the Docker Desktop API. *)

type service
(** The type for HTTP services. *)

val get : service -> string -> string Fut.t
(** [get s url] is the result of calling [GET <url>] on the service [s]. *)

val vm_service : t -> service
(** [vm_service t] is the service connected to the Docker Desktop virtual
    machine. *)

(** {1 User Notifications} *)

val success : t -> string -> unit
(** Display a toast message of type success. *)
