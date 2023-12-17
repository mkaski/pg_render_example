set search_path to api, public;

-- create a table for templates
create table templates (id text not null, template text not null);

-- create a table for products
create table products (id text not null, name text not null, price integer not null, description text not null, image_url text not null);

-- postgrest setup
grant select on products to web_anon;
grant select on templates to web_anon;

-- create example products
insert into products  (id, name, price, description, image_url) values
  ('1', 'Product 1', 100, 'Description 1', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Raven_Manet_E2_corrected.jpg/1920px-Raven_Manet_E2_corrected.jpg'),
  ('2', 'Product 2', 200, 'Description 2', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/THE_VIEW_%28Virtual_Reality%29.jpg/1920px-THE_VIEW_%28Virtual_Reality%29.jpg'),
  ('3', 'Product 3', 300, 'Description 3', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Stargazer_and_Pegasus_F43_in_flight_over_Atlantic_%28KSC-20161212-PH_LAL01_0009%29.jpg/2880px-Stargazer_and_Pegasus_F43_in_flight_over_Atlantic_%28KSC-20161212-PH_LAL01_0009%29.jpg');

-- create layout template
insert into templates (id, template) values ('layout', '
<html>
  <head>
    <title>{{ title }}</title>
    <style>{{ styles }}</style>
  </head>
  <body>
    {{ header }}
    {{ children }}
    {{ footer }}
  </body>
</html>
');

-- create header template
insert into templates (id, template) values ('header', '
<header>
  <h1>Layout Example</h1>
</header>
');

-- create footer template
insert into templates (id, template) values ('footer', '
<footer>
  <p>Footer content</p>
</footer>
');

-- create list of products template
insert into templates (id, template) values ('products', '
<ul>
  {% for product in rows %}
    <li>
      <h2>{{ product.name }}</h2>
      <p>{{ product.description }}</p>
      <p>$ {{ product.price }}</p>
      <img src="{{ product.image_url }}" />
    </li>
  {% endfor %}
</ul>
');

insert into templates (id, template) values ('styles', '
  body, html { margin: 0; padding: 0; }
  body {
    font-family: sans-serif;
  }
  header {
    background-color: #eee;
    padding: 1em;
  }
  footer {
    background-color: #eee;
    padding: 1em;
  }
  ul {
    list-style: none;
    padding: 0;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    grid-gap: 1em;
  }
  li {
    padding: 1em;
    border-bottom: 1px solid #eee;
  }
  img {
    max-width: 100%;
  }
');

-- serve full page using postgREST
create or replace function api.products() returns "text/html" as $$
  select render(
    (select template from templates where id = 'layout'),
    (json_build_object(
      'title', 'Products',
      'styles', (select template from templates where id = 'styles'),
      'header', (select template from templates where id = 'header'),
      'children', (select render(
          (select template from templates where id = 'products'),
          (select json_agg(to_json(products.*)) from products)
      )),
      'footer', (select template from templates where id = 'footer')
    ))
  );
$$ language sql stable;
