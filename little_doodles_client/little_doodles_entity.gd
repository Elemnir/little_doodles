class_name LittleDoodlesEntity extends Resource
## Data structure representing the Entity models in the LittleDoodles API

@export var name: String = ""
@export var kind: String = ""
@export var data: Dictionary = {}
@export var player_name: String = ""
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


## Returns a x-www-form-encoded string representing the entity suitable 
## for POST requests.
func as_request_body(csrf_token: String) -> String:
	return "csrfmiddlewaretoken=%s&name=%s&kind=%s&data=%s" % [
			csrf_token, name, kind, JSON.stringify(data)
	]
