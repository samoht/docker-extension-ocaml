FROM --platform=$BUILDPLATFORM ocaml/opam:alpine-ocaml-4.14 AS builder
RUN sudo apk add --update make libev-dev openssl-dev openssl-libs-static
ENV OPAMYES=1
ENV DUNE_CACHE=enabled
USER opam
WORKDIR /src
COPY hello.opam .
RUN --mount=type=cache,target=/opam/.cache/dune \
    opam install . --deps
COPY dune-project .
RUN sudo mkdir /out && sudo chown opam:opam /out

FROM builder AS vm
WORKDIR /src/vm
COPY vm/main.ml vm/dune .
RUN --mount=type=cache,target=/opam/.cache/dune \
    opam exec -- dune build --profile=static main.exe
RUN mv ../_build/default/vm/main.exe /out/service

FROM builder AS ui
WORKDIR /src/ui
COPY ui/ui.ml ui/dd.ml ui/dd.mli ui/dune ui/index.html .
RUN --mount=type=cache,target=/opam/.cache/dune \
    opam exec -- dune build --profile=release ui.bc.js
RUN mv ../_build/default/ui/ui.bc.js /out/ui.js && \
    mv index.html /out/index.html

FROM alpine
LABEL org.opencontainers.image.title="hello" \
    org.opencontainers.image.description="Test" \
    org.opencontainers.image.vendor="Tarides" \
    com.docker.desktop.extension.api.version=">= 0.2.3" \
    com.docker.extension.screenshots="" \
    com.docker.extension.detailed-description="" \
    com.docker.extension.publisher-url="" \
    com.docker.extension.additional-urls=""

COPY --from=vm /out/service /
COPY docker-compose.yaml .
COPY metadata.json .
COPY docker.svg .
COPY --from=ui /out ui
CMD /service -socket /run/guest-services/extension-hello.sock
