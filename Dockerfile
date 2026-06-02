# DeltaForge Compute Node
#
# Binary-install image: receives the signed deltaforge-compute binary via
# the Docker build context. No Rust toolchain, no source build.
#
# In CI: the build-containers workflow job extracts the binary from the
# signed Linux release tarball and places it in the build context before
# running docker build.
#
# For local use: pull ghcr.io/deltaforge-org/compute:<version>.
#
# Distroless runtime: no shell, no package manager, no curl.
# Includes glibc, OpenSSL, and ca-certificates (cc variant).
# Health checks must be configured at the orchestrator level:
#   ACI: livenessProbe / readinessProbe HTTP GET on BIND_PORT/health
#   Kubernetes: same, via the deployment spec
FROM gcr.io/distroless/cc-debian12:nonroot

COPY --chown=65532:65532 deltaforge-compute /usr/local/bin/deltaforge-compute

USER 65532

ENV CONTROL_PLANE_URL=http://control-plane:3000 \
    BIND_HOST=0.0.0.0 \
    BIND_PORT=8081 \
    MAX_CONCURRENT_QUERIES=16 \
    QUERY_TIMEOUT_SECS=300 \
    WORKER_THREADS=0 \
    ENABLE_RESULT_CACHE=true \
    RUST_LOG=info,delta_forge_compute=info

EXPOSE 8081

ENTRYPOINT ["/usr/local/bin/deltaforge-compute"]
