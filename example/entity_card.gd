extends MarginContainer

@onready var save_button = $HorizontalLayout/VerticalLayout/BottomLayout/SaveButton
@onready var player_label = $HorizontalLayout/VerticalLayout/BottomLayout/PlayerLabel
@onready var name_edit = $HorizontalLayout/VerticalLayout/NameEdit
@onready var kind_edit = $HorizontalLayout/VerticalLayout/KindEdit
@onready var data_edit = $HorizontalLayout/VerticalLayout/DataEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	# If the creator isn't the player, make the card readonly
	if $Entity.player_name != get_parent().player_name:
		name_edit.editable = false
		kind_edit.editable = false
		data_edit.editable = false
		save_button.visible = false
		player_label.text = "Creator: %s" % $Entity.player_name
	else:
		player_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
