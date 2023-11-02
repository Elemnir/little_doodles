class_name LittleDoodlesEntity extends Resource
## Data structure representing the Entity models in the LittleDoodles API

## The name of the entity
@export var name: String = ""

## The "kind" of thing that the entity is
@export var kind: String = ""

## Dictionary of supplementary entity data
@export var data: Dictionary = {}

## Name of the player who created the Entity
@export var player_name: String = ""

## Unique identifier for the Entity. Locally created Entities will have this as
## null until they are saved, after which it will be a String with the UUID
## which is suitable for passing to [method LittleDoodlesClient.get_entity] so
## that the entity can be retrieved later.
var uuid = null


## Returns a new Entity instance from the data structure provided by the
## server API. The user is responsible for adding the Entity to the node
## tree and freeing it as appropriate.
static func from_request_body(entitydef: Dictionary) -> LittleDoodlesEntity:
	var entity = new()
	entity.name = entitydef["name"]
	entity.kind = entitydef["kind"]
	entity.data = entitydef["data"]
	entity.uuid = entitydef["uuid"]
	entity.player_name = entitydef["player"]
	return entity


## Returns a JSON-encoded string representing the entity suitable 
## for POST requests.
func as_request_body() -> String:
	return JSON.stringify({
		"name": name,
		"kind": kind,
		"data": data,
	})
