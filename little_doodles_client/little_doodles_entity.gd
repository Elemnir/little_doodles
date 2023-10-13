class_name LittleDoodlesEntity extends Node

@export var kind: String = ""
@export var data: Dictionary = {}
@export var player_name: String = ""
var uuid = null


static func from_request_body(entitydef):
	var entity = new()
	entity.name = entitydef["name"]
	entity.kind = entitydef["kind"]
	entity.data = entitydef["data"]
	entity.uuid = entitydef["uuid"]
	entity.player_name = entitydef["player"]
	return entity


func as_request_body(csrf_token):
	return {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
