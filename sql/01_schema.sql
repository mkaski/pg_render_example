-- PostgREST setup
create extension pg_render;
create domain "text/html" as text;
create role anon nologin;
create role writer nologin;

grant usage on schema public to anon;
grant usage on schema public to writer;

create table posts (
    id serial not null primary key,
    title text not null,
    content text not null,
    image_url text,
    likes integer default 0 not null
);

create table templates (
    id text not null primary key,
    template text not null
);

create table analytics (
    post_id integer references posts (id) not null,
    created_at timestamptz not null default now()
);

-- postgrest permissions
grant select on posts to anon;
grant select on templates to anon;
grant select on analytics to anon;
grant insert on analytics to anon;

grant select on posts to writer;
grant update on posts to writer;

--- PAGES ---

-- all posts
create or replace function index(page integer default 1) returns "text/html" as $$
    select render(
        (select template from templates where id = 'layout'),
        (json_build_object(
            'title',   'All Posts',
            'styles',    (select template from templates where id = 'styles.css'),
            'header',    (select template from templates where id = 'header'),
            'footer',    (select template from templates where id = 'footer'),
            'load_more', (select render(
                (select template from templates where id = 'posts/load-more'),
                (json_build_object('next_page', (page + 1), 'children', '<nav></nav>')
            ))),
            'children',  (select render_agg(
                (select template from templates where id = 'posts/list-post'), posts) from
                (select id, title, content, image_url, likes from posts order by id limit 3 offset ($1 - 1) * 3) as posts
            ))
        )
    );
$$ language sql;

-- single post
create or replace function post(id integer)
returns "text/html" as $$
    select render(
        (select template from templates where id = 'layout'),
        (json_build_object(
            'title',     (select title from posts where id = $1),
            'styles',    (select template from templates where id = 'styles.css'),
            'header',    (select template from templates where id = 'header'),
            'footer',    (select template from templates where id = 'footer'),
            -- re-use for analytics
            'load_more', (select render ('<input type="hidden" hx-trigger="load" hx-post="/analytics" name="post_id" value="{{ value }}" hx-headers=''{"Accept": "application/json"}'' />', $1)
            ),
            'children',  (select render(
                (select template from templates where id = 'posts/post'),
                (select to_json(posts) from (
                    select id, title, content, image_url, likes, a.views from posts
                    left join (select post_id, count(*) as views from analytics group by post_id) a on posts.id = a.post_id
                    where id = $1
                ) posts)
            ))
        ))
    );
$$ language sql;

--- RPC ---

create or replace function like(id integer)
returns "text/html" as $$
declare
    updated_likes integer;
begin
    set local role writer;
    update posts set likes = likes + 1 where posts.id = $1 returning likes into updated_likes;
    return updated_likes;
end;
$$ language plpgsql;

create or replace function load_more(page integer default 1)
returns "text/html" as $$
    select render(
        (select template from templates where id = 'posts/load-more'),
        (json_build_object(
            'next_page', (select (page + 1)),
            'children', (select render_agg(
                (select template from templates where id = 'posts/list-post'), posts)
                from (select id, title, content, image_url, likes from posts order by id limit 3 offset ($1 - 1) * 3) as posts
            ))
        )
    );
$$ language sql;
