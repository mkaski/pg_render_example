-- init pg_render extension
create extension if not exists pg_render;

-- PostgREST setup
create domain "text/html" as text;
grant usage on schema api to web_anon;

-- hello world index page
create or replace function api.index() returns "text/html" as $$
  select render('
  <html>
    <head>
      <title>{{ title }}</title>
    </head>
    <body>
      {{ title }}
    </body>
  </html>',
    (json_build_object('title', 'Hello World'))
  );
$$ language sql stable;