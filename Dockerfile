ARG PG_VERSION=18

# ── Build stage ──────────────────────────────────────────────────────────────
FROM postgres:${PG_VERSION} AS builder

ENV build_deps="ca-certificates git openssh-client build-essential libpq-dev postgresql-server-dev-${PG_MAJOR} curl libreadline-dev zlib1g-dev pkg-config cmake"

RUN apt-get update && apt-get install -y --no-install-recommends $build_deps

WORKDIR /home/pg_render

RUN git clone --depth 1 --branch v0.1.3 https://github.com/mkaski/pg_render.git .

ENV PATH="/home/pg_render/.cargo/bin:${PATH}" \
    HOME=/home/pg_render

RUN chown -R postgres:postgres /home/pg_render
USER postgres

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    --no-modify-path --profile minimal --default-toolchain nightly && \
    rustup --version && \
    rustc --version && \
    cargo --version

RUN cargo install cargo-pgrx --version 0.16.1 --locked
RUN cargo pgrx init --pg${PG_MAJOR} $(which pg_config)

USER root
RUN cargo pgrx install

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM postgres:${PG_VERSION}

COPY --from=builder \
    /usr/lib/postgresql/${PG_MAJOR}/lib/pg_render.so \
    /usr/lib/postgresql/${PG_MAJOR}/lib/

COPY --from=builder \
    /usr/share/postgresql/${PG_MAJOR}/extension/pg_render.control \
    /usr/share/postgresql/${PG_MAJOR}/extension/pg_render--*.sql \
    /usr/share/postgresql/${PG_MAJOR}/extension/

USER postgres
