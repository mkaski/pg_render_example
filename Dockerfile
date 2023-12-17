# pg_render_postgres
# Use the official PostgreSQL image as the base image
FROM postgres:15

# Set environment variables for PostgreSQL
ENV POSTGRES_DB=db
ENV POSTGRES_USER=myuser
ENV POSTGRES_PASSWORD=mypassword

# Switch to the root user to install the custom extension
USER root

# Install necessary dependencies, including ca-certificates
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        ca-certificates \
        postgresql-server-dev-all \
    && rm -rf /var/lib/apt/lists/*

# Download and install the custom extension .deb package
WORKDIR /tmp
# TODO: This for AMD64 only, need to add ARM64 support
RUN wget https://github.com/mkaski/pg_render/releases/download/v0.5.0/pg_render-v0.5.0-pg15-amd64-linux-gnu.deb \
    && dpkg -i pg_render-v0.5.0-pg15-amd64-linux-gnu.deb \
    && apt-get install -f \
    && rm -rf pg_render-v0.5.0-pg15-amd64-linux-gnu.deb

# Switch back to the postgres user
USER postgres

# Expose the PostgreSQL port
EXPOSE 5432

# Start PostgreSQL
CMD ["postgres"]
