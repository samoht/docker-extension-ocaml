### Template for create Docker extension in OCaml

### Usage

Install Docker extension: https://docs.docker.com/desktop/extensions/

To try it:

```shell
$ docker extension install tarides/hello
```

### How it works

#### UI

The `ui/` code runs in the same process as Docker for Desktop electron UI.
It is compiled to Javascript with `js_of_ocaml` and hot-loaded by the
`docker extension` command.

[ui/dd.ml](https://github.com/samoht/docker-extension-ocaml/blob/main/ui/dd.mli)
is a very minimal binding to the Docker Desktop Client API.
It's using the wonderful [Brr](https://erratique.ch/software/brr/doc/index.html).

#### VM

The `vm/` code runs inside the Linux VM, as a container. It uses a slighlty
modified version of Dream that allows to start HTTP servers listening on
Unix domain sockets. `docker extension` starts the container in the VM and
connects the relevant sockets so that the UI can talk to the backend using
REST calls.
