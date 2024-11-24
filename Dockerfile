ARG PG_VERSION=16
FROM postgres:${PG_VERSION}
RUN apt-get update

ENV build_deps="ca-certificates git openssh-client build-essential libpq-dev postgresql-server-dev-${PG_MAJOR} curl libreadline6-dev zlib1g-dev"

RUN apt-get install -y --no-install-recommends $build_deps pkg-config cmake

WORKDIR /home/pg_render

# Clone pg_render repo from GitHub using HTTPS URL
RUN git clone https://github.com/mkaski/pg_render.git .

ENV PATH="/home/pg_render/.cargo/bin:${PATH}" \
  HOME=/home/pg_render
RUN chown -R postgres:postgres /home/pg_render
USER postgres

RUN \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain nightly && \
  rustup --version && \
  rustc --version && \
  cargo --version

# PGRX
RUN cargo install cargo-pgrx --version 0.12.8 --locked
RUN cargo pgrx init --pg${PG_MAJOR} $(which pg_config)

USER root

RUN cargo pgrx install

USER postgres