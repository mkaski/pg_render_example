# PostgREST + pg_render + HTMX

Example blog implementation with infinite scrolling, and dynamic "Like" button for posts using only declarative SQL and HTMX.

- [pg_render](https://github.com/mkaski/pg_render)
- [PostgREST](https://postgrest.org)
- [htmx](https://htmx.org)

## Getting started

```bash
# Build pg_render and start a PostgREST server with the extension

$ docker-compose up

# Navigate to http://localhost:3000/
```