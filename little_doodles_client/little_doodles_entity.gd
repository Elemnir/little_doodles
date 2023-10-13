class_name LittleDoodlesEntity extends Node

@export var kind: String = ""
@export var data: Dictionary = {}
@export var player_name: String = ""
var uuid = null


static func from_request_body(entitydef: Dictionary) -> LittleDoodlesEntity:
	# Returns a new Entity instance from the data structure provided by the
	# server API. The user is responsible for adding the Entity to the node
	# tree and freeing it as appropriate.
	var entity = new()
	entity.name = entitydef["name"]
	entity.kind = entitydef["kind"]
	entity.data = entitydef["data"]
	entity.uuid = entitydef["uuid"]
	entity.player_name = entitydef["player"]
	return entity


func as_request_body(csrf_token: String) -> String:
	# Returns a JSON-encoded string representing the entity suitable 
	# for POST requests.
	return JSON.stringify({
		"csrfmiddlewaretoken": csrf_token,
		"name": name,
		"kind": kind,
		"data": data,
	})
