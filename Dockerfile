FROM ocaml/opam:alpine-ocaml-4.14 AS builder
RUN sudo apk add --update make libev-dev openssl-dev openssl-libs-static
ENV OPAMYES=1
ENV DUNE_CACHE=enabled
USER opam
WORKDIR /backend
COPY hello.opam .
RUN --mount=type=cache,target=/opam/.cache/dune \
    opam install . --deps
COPY vm/main.ml vm/dune vm/dune-project .
RUN --mount=type=cache,target=/opam/.cache/dune \
    opam exec -- dune build main.exe
RUN mkdir bin && mv _build/default/main.exe bin/service

FROM --platform=$BUILDPLATFORM node:17.7-alpine3.14 AS client-builder
WORKDIR /ui
# cache packages in layer
COPY ui/package.json /ui/package.json
COPY ui/package-lock.json /ui/package-lock.json
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm ci
# install
COPY ui /ui
RUN npm run build

FROM alpine
LABEL org.opencontainers.image.title="hello" \
    org.opencontainers.image.description="Test" \
    org.opencontainers.image.vendor="Tarides" \
    com.docker.desktop.extension.api.version=">= 0.2.3" \
    com.docker.extension.screenshots="" \
    com.docker.extension.detailed-description="" \
    com.docker.extension.publisher-url="" \
    com.docker.extension.additional-urls=""

COPY --from=builder /backend/bin/service /
COPY docker-compose.yaml .
COPY metadata.json .
COPY docker.svg .
COPY --from=client-builder /ui/build ui
CMD /service -socket /run/guest-services/extension-hello.sock
