# LittleDoodles Django Server 

This directory contains the Django project for the LittleDoodles Server. The
layout is pretty standard, but the most important pieces are:

  * `little_doodles/settings.py` - The Django project configuration for things
    like databases, logging, and authentication.
  * `little_doodles/urls.py` - The central URL config for routing requests.
  * `game_server/models.py` - Where the Entity model is defined.
  * `game_server/views.py` - Where all of the Views are defined.
  * `game_server/urls.py` - Contains the mapping of URLs to Views.
  * `manage.py` - the entrypoint script for Django admin commands like running
    the server.
  * `requirements.txt` - the list of server dependencies which need to be
    installed.


## The Admin Site

One of the best features of Django is its ability to generate an admin interface
for interacting with the database contents directly without needing to break out
the SQL.

To use it, a User must be created which has `is_staff=True`. The quickest way to
do this is via the `manage.py` CLI: `./manage.py createsuperuser`

Follow the prompts and it will create the user. Next, start the server, then, in
a browser, navigate to `/admin/`. Log in with the superuser credentials you just
set, and you should be good to go!

(Note: No, users created by the `/user/add/` endpoint in Godot or otherwise will
NOT be set as staff and therefore will not be able to access the admin unless
you edit them to be staff from within it.)


## How-To Cookbooks

While the quickstart is sufficient for getting the system working, the rest of
this document will cover several different scenarios to give an idea of how the
system can be updated and expanded when needed.

### Changing out the database

By default the server uses SQLite as the database backend and stores it in
`db.sqlite3`. While this is fine for testing or small projects, you'll probably
want something more substantial like Postgres or MySQL. Once you have your
database server of choice set up, go into `little_doodles/settings.py` and edit
the `DATABASES` setting as described in [these docs][django-databases] or using
the options outlined [here][django-settings-databases].

### Extending the Entity Model

The free-form `data` field on the entity allows storage of arbitrary data as
JSON, but this can be difficult to search and can't be indexed when there are
many entities in the database. You can add or alter whatever fields you want on
the model as described in [this reference][django-models].

To update the database, after making your changes, you can generate a new
database migration template using `./manage.py makemigrations`. This will create
a new module in `game_server/migrations/` which tells Django how to execute the
changes you made to the database. If you want, you can alter this module to
handle things like populating new fields in existing rows with a fixed or 
calculated value. The relevant documentation can be found
[here][django-migrations]. 

When you are ready, apply the migration with `./manage.py migrate`. When adding
fields, it will be necessary to also update the client-side as well as 
`game_server/views.py` to include the new fields in JSON payloads or in the
fields of the `EntityForm` so that they are properly validated and updated.


[django-databases]: https://docs.djangoproject.com/en/4.2/ref/databases/
[django-settings-databases]: https://docs.djangoproject.com/en/4.2/ref/settings/#databases
[django-models]: https://docs.djangoproject.com/en/4.2/ref/models/fields/
[django-migrations]: https://docs.djangoproject.com/en/4.2/topics/migrations/
