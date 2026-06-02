# DeltaForge Compute Node

The DeltaForge compute node (worker): the process that executes queries. It
connects to a DeltaForge control plane, pulls work, and runs each query on a
single node. Scale out by running more compute nodes against the same control
plane.

This repo is the dedicated distribution + support home for the compute node:
release binaries, the container image, and a Dockerfile, so a worker can be
pre-shipped in your own images. The compute node also ships inside the full
DeltaForge package.

Learn more at **[deltaforge.org](https://deltaforge.org)**.

DeltaForge is commercial software with a free Community license. See
[deltaforge.org/pricing](https://deltaforge.org/pricing).

## Docker (worker pre-shipped)

A distroless image with the compute node baked in is published on every release:

```bash
docker pull ghcr.io/deltaforge-org/compute:latest

docker run --rm \
  -e CONTROL_PLANE_URL=https://control.example.com \
  -e BIND_HOST=0.0.0.0 -e BIND_PORT=8081 \
  -p 8081:8081 \
  ghcr.io/deltaforge-org/compute:latest
```

To bake the worker into your own image, use the [`Dockerfile`](Dockerfile) in
this repo with the released binary in the build context:

```bash
# Download the compute-node binary for your platform from the Releases page,
# place deltaforge-compute next to the Dockerfile, then:
docker build -t my-org/deltaforge-compute .
```

## Binary install

Download the compute-node binary for your platform from the
[Releases](https://github.com/deltaforge-org/delta-forge-compute/releases) page
(Linux/macOS tarball, Windows zip), then run it pointed at your control plane:

```bash
CONTROL_PLANE_URL=https://control.example.com \
BIND_HOST=0.0.0.0 BIND_PORT=8081 \
  ./deltaforge-compute
```

## Configuration

| Env var | Default | Meaning |
| --- | --- | --- |
| `CONTROL_PLANE_URL` | `http://control-plane:3000` | Control plane to register with |
| `BIND_HOST` | `0.0.0.0` | Listen address |
| `BIND_PORT` | `8081` | Listen port |
| `MAX_CONCURRENT_QUERIES` | `16` | Concurrency ceiling |
| `QUERY_TIMEOUT_SECS` | `300` | Per-query timeout |
| `WORKER_THREADS` | `0` (auto) | Tokio worker threads |
| `ENABLE_RESULT_CACHE` | `true` | In-process result cache |

The control plane (server) is published separately with the full DeltaForge
package; the compute node connects to it.

## Support

Issues and questions:
[github.com/deltaforge-org/delta-forge-compute/issues](https://github.com/deltaforge-org/delta-forge-compute/issues).
