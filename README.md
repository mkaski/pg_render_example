# PostgREST + pg_render

This is a simple example of using PostgREST with pg_render to render HTML in SQL.

## Build

```bash
# Build postgres with the extension installed
docker build -t pg_render_postgres .
# Run PostgREST with the db
docker-compose up
# Navigate to http://localhost:3000/rpc/index
```

## Examples

See the [sql](sql) directory for more SQL schema examples.