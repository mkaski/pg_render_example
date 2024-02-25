insert into templates (id, template) values
    ('layout', '
    <!DOCTYPE html>
    <html>
        <head>
            <title>{{ title }}</title>
            <style>{{ styles }}</style>
            <script src="https://unpkg.com/htmx.org@2.0.0-alpha1/dist/htmx.min.js"></script>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body hx-headers=''{"Accept": "text/html"}''>
            {{ header }}
            <main>
                {{ children }}
                {{ load_more }}
            </main>
            {{ footer }}
        </body>
    </html>'
);

insert into templates (id, template) values
    ('header', '
    <header>
        <h1><a href="/">pgrender.org</a></h1>
        <h4>Example site running pg_render, PostgREST and HTMX</h4>
        <code><a href="https://github.com/mkaski/pg_render_example">View source</a></code>
    </header>'
);

insert into templates (id, template) values
    ('footer', '
    <footer>
        <small><a href="https://github.com/mkaski/pg_render">pg_render</a></small>
    </footer>'
);

insert into templates (id, template) values
    ('posts/list-post', '
    <article>
        <form hx-post="/rpc/like" hx-target="find span">
            <button name="id" value="{{ id }}" type="submit">
                Like
            </button>
            <label><span>{{ likes }}</span> likes</label>
        </form>
        <a href="/post/{{ id }}">
            <h2>{{ title }}</h2>
        </a>
        <section>{{ content }}</section>
        <img src="{{ image_url }}" alt="{{ title }}">
    </article>'
);

insert into templates (id, template) values
    ('posts/post', '
    <article>
        <form>
            <span>{{ likes }} likes</span>
            <span>{{ views }} views</span>
        </form>
        <h1>{{ title }}</h1>
        <section>{{ content }}</section>
        <img src="{{ image_url }}" alt="{{ title }}">
    </article>'
);

insert into templates (id, template) values
    ('posts/load-more', '
    {% if children != blank %}
        {{ children }}
        <nav hx-get="/rpc/load_more?page={{ next_page }}" hx-trigger="revealed" hx-swap="afterend" />
    {% endif %}
    <div class="htmx-indicator">Loading...</div>
');

insert into templates (id, template) values
    ('styles.css', '
    body {
        margin: 0;
        padding: 0;
        font-family: system-ui, sans-serif;
    }
    header {
        text-align: center;
    }
    h4 {
        margin-top: -1rem;
        margin-bottom: 2rem;
        font-weight: 300;
    }
    main {
        width: 600px;
        max-width: 100%;
        margin: 1rem auto;
        @media (max-width: 600px) {
            width: 90%;
        }
    }
    article {
        border: 1px solid #888;
        margin-bottom: 1.25rem;
        padding: 1rem;
        opacity: 1;
        transition: opacity 500ms ease;
    }
    article.htmx-added {
        opacity: 0;
    }
    form {
        display: flex;
        align-items: center;
        gap: 1rem;
    }
    button {
        display: flex;
        padding: 0.25rem;
    }
    img {
        width: 100%;
        max-width: 100%;
        max-height: calc((600px * 9) / 16);
        object-fit: cover;
        display: block;
    }
    section {
        margin: 1rem 0;
    }
    footer {
        text-align: center;
        padding: 2rem;
    }
    nav {
        text-align: center;
        position: absolute;
        right: 1rem;
    }
');
