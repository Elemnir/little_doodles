extends MarginContainer

@export var root_scene: Node

@onready var save_button = $HorizontalLayout/VerticalLayout/BottomLayout/SaveButton
@onready var player_label = $HorizontalLayout/VerticalLayout/BottomLayout/PlayerLabel
@onready var name_edit = $HorizontalLayout/VerticalLayout/NameEdit
@onready var kind_edit = $HorizontalLayout/VerticalLayout/KindEdit
@onready var data_edit = $HorizontalLayout/VerticalLayout/DataEdit

var entity = LittleDoodlesEntity.new()

func _ready():
	name_edit.text = entity.name
	kind_edit.text = entity.kind
	data_edit.text = JSON.stringify(entity.data, "  ")
	
	# If the creator isn't the player, make the card readonly
	if entity.player_name != root_scene.player_name:
		name_edit.editable = false
		kind_edit.editable = false
		data_edit.editable = false
		save_button.visible = false
		player_label.text = "Creator: %s" % entity.player_name
	else:
		player_label.visible = false


func _on_save_button_pressed():
	entity.name = name_edit.text
	entity.kind = kind_edit.text
	entity.data = JSON.parse_string(data_edit.text)
	root_scene.try_save(entity)
