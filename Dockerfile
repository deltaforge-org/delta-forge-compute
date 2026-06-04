# DeltaForge Compute Node
#
# Binary-install image: receives the signed deltaforge-compute binary via the
# Docker build context. No Rust toolchain, no source build.
#
# In CI: the compute-release workflow extracts the binary from the signed Linux
# release tarball and places it in the build context before running docker build.
#
# For local use: pull ghcr.io/deltaforge-org/compute:<version>.
#
# Runtime base: debian-slim with the Vulkan loader (libvulkan1) and the Mesa
# Vulkan ICDs. The compute node dlopens libvulkan.so.1 only when GPU operators
# are enabled (DELTAFORGE_GPU_OPERATORS); without a GPU it runs CPU-only. When
# the container is scheduled on a GPU host, the GPU vendor driver and ICD are
# provided at runtime by the container runtime (for NVIDIA, the Container
# Toolkit via --gpus / runtime=nvidia, honoring NVIDIA_DRIVER_CAPABILITIES).
# Mesa supplies AMD/Intel ICDs and an llvmpipe software fallback.
#
# Health checks must be configured at the orchestrator level:
#   ACI: livenessProbe / readinessProbe HTTP GET on BIND_PORT/health
#   Kubernetes: same, via the deployment spec
FROM debian:12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      libvulkan1 \
      mesa-vulkan-drivers \
 && rm -rf /var/lib/apt/lists/*

# Non-root runtime user, uid/gid 65532 to match the previous distroless nonroot.
RUN groupadd --gid 65532 nonroot \
 && useradd --uid 65532 --gid 65532 --no-create-home --shell /usr/sbin/nologin nonroot

COPY --chown=65532:65532 deltaforge-compute /usr/local/bin/deltaforge-compute

USER 65532

ENV CONTROL_PLANE_URL=http://control-plane:3000 \
    BIND_HOST=0.0.0.0 \
    BIND_PORT=8081 \
    MAX_CONCURRENT_QUERIES=16 \
    QUERY_TIMEOUT_SECS=300 \
    WORKER_THREADS=0 \
    ENABLE_RESULT_CACHE=true \
    RUST_LOG=info,delta_forge_compute=info \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,graphics,utility

EXPOSE 8081

ENTRYPOINT ["/usr/local/bin/deltaforge-compute"]
