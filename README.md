# LittleDoodles Simple Game Server [![Made for Godot 4.1+][badge]][godot]

A server and client system for loosely connected multiplayer game elements.
Potential use cases include:

  * Leaderboards and high score tracking
  * Souls-like player messages
  * Sharing of player structures such as Death Stranding's Social Strand System
  * Session authentication or "CD key" validation systems

NOTE: This is not intended for real-time multiplayer elements, as it relies on
[HTTPRequest][godot-http] and is optimized for ease of use and flexibility over
performance.

The client is a pure GDScript implementation and the server is built in Python
using Django. The server has only been tested on Linux.

## Usage

More detailed documentation on each component can be found in the relevant
subdirectory's readme, but here's a quick summary:

```gd
func _ready():
	var client = LittleDoodlesClient.new()
	client.api_url = "https://example.com"
	if await client.auth_user("username", "password"):
		var entities = await client.search_entities("kind=score")
	else:
		pass #Authentication failed!
```

In this example, an instance of the client is created and the server domain is
set. Next, an attempt is made to authenticate, and if it returns true, then the
search is performed for any entities whose "kind" is equal to "score". The
returned entities is a list of LittleDoodlesEntity resources with a name, kind,
associated player name for who created them, and a data field for any arbitrary
data, stored as a Dictionary.

```gd
func _ready():
	var highscore = LittleDoodlesEntity.new()
	highscore.name = "<playername>_highscore"
	highscore.kind = "highscore"
	highscore.data = {"score": 9999}
	if await client.save_entity(highscore):
		print("Score saved successfully!")
	else:
		print("Save failed!")
```

Persisting and modifying data on the server is straightforward. In the above
example, a new Entity is created and populated, and then a previously
instantiated client is invoked to save the Entity. Client instances will save
authentication credentials between calls, and can deduce whether the provided
Entity needs to be created on the server as new or simply modified.

As for the server, the Django documentation provides examples of many 
[deployment scenarios][django-deploy], and the settings are highly customizable,
but to simply get a development sandbox working on a Linux system, the following
should be sufficient:

```
cd little_doodles_server/
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp little_doodles/keys.sh.template keys.sh
# Edit keys.sh with your hostname and set a large, random string for the secret key
source keys.sh
./manage.py migrate
./manage.py runserver 0.0.0.0:8000
```

This will create a new Python Virtual Environment, activate it, install Django,
then create the database and tables (uses Sqlite by default), and starts the
development server on port 8000 running over HTTP.

Also, note the `keys.sh` file is intended to contain secrets for your project
and shouldn't be committed to a repo or shared!

[badge]: https://flat.badgen.net/badge/made%20for/Godot%204.1%2b/478cbf
[django-deploy]: https://docs.djangoproject.com/en/4.2/howto/deployment/
[godot]: https://godotengine.org/
[godot-http]: https://docs.godotengine.org/en/stable/tutorials/networking/http_request_class.html
