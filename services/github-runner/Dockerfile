# Runner image for spacesonar-pro: the upstream runner plus the build dependencies of the Rust crates.
FROM myoung34/github-runner:ubuntu-noble

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        libssl-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# rustup and the toolchain live in the home volume, installed by the entrypoint on the first start.
ENV PATH=/root/.cargo/bin:${PATH}

COPY entrypoint-rust.sh /entrypoint-rust.sh
RUN chmod +x /entrypoint-rust.sh

ENTRYPOINT ["/entrypoint-rust.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
