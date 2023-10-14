extends Node2D

@onready var api_client = $LittleDoodlesClient
@onready var username = $AuthForm/Username
@onready var password = $AuthForm/Password
@onready var search_box = $EntityControls/SearchBox
@onready var user_indicator = $AuthenticatedForm/UserIndicator
@onready var entity_grid = $EntityWindow/GridContainer

var player_name = ""


func try_save(entity: LittleDoodlesEntity):
	if await api_client.save_entity(entity):
		$FeedbackBox.text = "Save success!"
	else:
		$FeedbackBox.text = "Save failed"

func _on_create_entity_button_pressed():
	var new_card = preload("res://example/EntityCard.tscn").instantiate()
	new_card.root_scene = self
	new_card.entity.player_name = player_name
	entity_grid.add_child(new_card)


func _on_search_button_pressed():
	var entities = await api_client.search_entities(search_box.text)
	if entities == null:
		$FeedbackBox.text = "Search failed"
		return
		
	for entity in entities:
		var new_card = preload("res://example/EntityCard.tscn").instantiate()
		new_card.root_scene = self
		new_card.entity = entity
		entity_grid.add_child(new_card)


func _on_login_button_pressed():
	if await api_client.auth_user(username.text,password.text):
		$AuthForm.visible = false
		$AuthenticatedForm.visible = true
		user_indicator.text = "Logged in as: " + username.text
		player_name = username.text
		$FeedbackBox.text = "Successful Login"
	else:
		$FeedbackBox.text = "Login Failed"


func _on_create_player_button_pressed():
	if await api_client.create_user(username.text,password.text):
		$AuthForm.visible = false
		$AuthenticatedForm.visible = true
		user_indicator.text = "Logged in as: " + username.text
		player_name = username.text
		$FeedbackBox.text = "Successful Create and Login"
	else:
		$FeedbackBox.text = "Create User Failed"


func _on_clear_entity_grid_pressed():
	for card in entity_grid.get_children():
		card.queue_free()
