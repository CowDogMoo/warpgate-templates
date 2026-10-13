# throwingshade Container Image

Small image that carries one pinned build of the
[throwingshade](https://github.com/CowDogMoo/throwingshade) CLI (`ts`), a
statically linked Go binary for controlling motorized window shades. It exists
so a Kubernetes workload can copy a known `ts` into a shared volume at pod
start instead of relying on a binary copied in by hand.

## What the Image Contains

- `/ts`, built with `CGO_ENABLED=0` for `linux/arm64`, with the version, commit,
  and build date embedded through the same `-ldflags` variables throwingshade's
  own build sets (`ts --version` prints them)
- BusyBox, so an init container can run `cp /ts /dest/ts`
- Entrypoint `/ts`, default user `65534:65534`
- OCI labels with the source commit (`org.opencontainers.image.revision`) and
  the `git describe` style version (`org.opencontainers.image.version`)

Both base images (`golang` for the build stage and `busybox` for the final
stage) are pinned by digest in the [Dockerfile](./Dockerfile).

## Tags

The image is tagged with the full 40-character throwingshade commit SHA it
was built from, for example:

```text
ghcr.io/cowdogmoo/throwingshade:36f3914aeb592f38a9a466c9e23a13ac8bb9c1ab
```

There is no `latest` or other floating tag. To update the binary, build a new
commit and point the consumer at the new tag.

## Private Source Without Credentials in the Build

The throwingshade repository is private. Warpgate's Dockerfile builds do not
forward BuildKit secrets or an SSH agent, so the source is not cloned inside
the build. Instead, `fetch-source.sh` downloads the GitHub source archive for
the pinned commit on the build host, using the GitHub CLI's existing login (or
`GH_TOKEN`), and writes it to `throwingshade-src.tar.gz` in this directory.
That archive is the only file sent as build context (see `.dockerignore`).

The credential stays on the host: it never enters BuildKit, an image layer, or
the build cache. The archive itself is git-ignored.

The build refuses to compile anything but the requested commit. GitHub source
archives record the commit they were made from in the tar header, and the
Dockerfile compares that ID (`git get-tar-commit-id`) against the
`THROWINGSHADE_REF` build argument before compiling.

## Building and Pushing

Requirements:

- Warpgate and a running BuildKit builder
  (`docker buildx create --use --driver docker-container --bootstrap`)
- `gh` logged in to an account that can read the throwingshade repository
- `docker login ghcr.io` with a token that has the `write:packages` scope
  (only needed to push)

Build and push one commit:

```bash
cd templates/throwingshade

REF=<full 40-character throwingshade commit SHA>
# Prints the git-describe style version, e.g. v2.1.1-14-g36f3914
VERSION="$(./fetch-source.sh "$REF")"

warpgate build warpgate.yaml \
  --arch arm64 \
  --var THROWINGSHADE_REF="$REF" \
  --var THROWINGSHADE_VERSION="$VERSION" \
  --registry ghcr.io/cowdogmoo \
  --push
```

Leave off `--push` to build into the local Docker image store only. To build
the current `main` commit, resolve it first:

```bash
REF="$(gh api repos/CowDogMoo/throwingshade/commits/main --jq .sha)"
```

### Verifying the Image

These commands only print local information; they do not contact any shade
hardware:

```bash
IMAGE="ghcr.io/cowdogmoo/throwingshade:$REF"
docker run --rm --network none --platform linux/arm64 "$IMAGE" --version
docker run --rm --network none --platform linux/arm64 "$IMAGE" --help
```

## Architecture

Only `linux/arm64` is built, because that is where the consumer runs. The
build stage cross-compiles on the build host's native platform, so adding
`linux/amd64` to the `platforms` list and passing `--arch amd64` is all another
architecture needs.

## CI

The repository's build-and-push workflow skips this template: it has no
access to the private source and would publish a floating `latest` tag. Build
and push it by hand with the commands above.

## Using the Image from Kubernetes

Keep the package private, like the source repository it is built from. A
cluster then needs an image pull secret (`kubernetes.io/dockerconfigjson`) for `ghcr.io`
holding a token with `read:packages`. A typical consumer copies the binary
into a shared volume with an init container:

```yaml
initContainers:
  - name: install-ts
    image: ghcr.io/cowdogmoo/throwingshade:<commit-sha>
    command: ["cp", "/ts", "/dest/ts"]
    securityContext:
      runAsUser: <volume-owner-uid>
      runAsGroup: <volume-owner-gid>
    volumeMounts:
      - name: shared
        mountPath: /dest
```

The image defaults to the non-root user `65534`, so the copy into a shared
volume only works when the init container runs as a user that can write that
volume. Set `runAsUser` and `runAsGroup` to the uid and gid that own the
volume, normally the same user as the pod that runs `ts`. Use root (`0`) only
if the volume requires it.
