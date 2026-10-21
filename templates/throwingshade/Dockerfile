# Builds the throwingshade CLI (ts) from a source archive that fetch-source.sh
# downloads on the build host. The archive is the only input from the private
# repository, so no credential ever reaches BuildKit, a layer, or the cache.
ARG GO_IMAGE=golang:1.27.3-bookworm@sha256:21ade014faf952365b9ecbd8dbdb87176fbacb82fac9fb132d9f2a7b8cc3f132
ARG RUNTIME_IMAGE=busybox:1.38.0@sha256:fd7dc98638c8e305f4dc34e979f1c0fdfdcaeb0fbf8fcff77ae834b6da3d7e6e

FROM --platform=$BUILDPLATFORM ${GO_IMAGE} AS build

ARG THROWINGSHADE_REF
ARG THROWINGSHADE_VERSION
ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0 \
    GOFLAGS=-mod=readonly \
    GOTOOLCHAIN=local

WORKDIR /src

COPY throwingshade-src.tar.gz /tmp/throwingshade-src.tar.gz

# Build only the pinned commit: GitHub source archives record the commit they
# were made from in the tar header, so a stale or swapped archive fails here.
RUN set -eu; \
    if ! echo "${THROWINGSHADE_REF}" | grep -Eq '^[0-9a-f]{40}$'; then \
      echo "THROWINGSHADE_REF must be a full 40-character commit SHA" >&2; \
      exit 1; \
    fi; \
    archived="$(gzip -dc /tmp/throwingshade-src.tar.gz | git get-tar-commit-id)"; \
    if [ "${archived}" != "${THROWINGSHADE_REF}" ]; then \
      echo "source archive is commit '${archived}', expected ${THROWINGSHADE_REF}; rerun fetch-source.sh" >&2; \
      exit 1; \
    fi; \
    tar -xzf /tmp/throwingshade-src.tar.gz --strip-components=1

# Same version variables throwingshade's own build sets.
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    set -eu; \
    pkg=github.com/cowdogmoo/throwingshade/cmd; \
    GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" go build -trimpath \
      -ldflags "-s -w \
        -X ${pkg}.Version=${THROWINGSHADE_VERSION:-${THROWINGSHADE_REF}} \
        -X ${pkg}.GitCommit=${THROWINGSHADE_REF} \
        -X ${pkg}.BuildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      -o /out/ts .

FROM ${RUNTIME_IMAGE}

ARG THROWINGSHADE_REF
ARG THROWINGSHADE_VERSION

LABEL org.opencontainers.image.source="https://github.com/CowDogMoo/throwingshade"
LABEL org.opencontainers.image.description="throwingshade CLI (ts) pinned to one commit"
LABEL org.opencontainers.image.revision="${THROWINGSHADE_REF}"
LABEL org.opencontainers.image.version="${THROWINGSHADE_VERSION}"

# busybox stays in the image so a Kubernetes init container can copy /ts into
# a shared volume (cp /ts /dest/ts).
COPY --from=build /out/ts /ts

USER 65534:65534

ENTRYPOINT ["/ts"]
CMD ["--help"]
