
```bash
# Build postgres with the extension installed
docker build -t pg_render_postgres .
# Run PostgREST with the db
docker-compose up
# Navigate to http://localhost:3000/rpc/index
```