class_name LittleDoodlesClient extends HTTPRequest

var scheme = "https"
var domain = "oatestbed.adamphoward.com/game/"
var api_url = "%s://%s" % [scheme, domain]
var cookiejar = {}


func create_user(username, password):
	pass


func auth_user(username, password):
	pass


func save_entity(entity):
	# Create the Entity on the server if it doesn't already have a UUID,
	# otherwise update it. Returns true if the save completed successfully
	var endpoint = "entity/add/" if entity.uuid == null else "entity/%s/" % entity.uuid
	var resp = await _send_request(endpoint)
	if resp == null:
		return false
	resp = await _send_request(
		endpoint, HTTPClient.METHOD_POST, entity.as_request_body(resp["csrf_token"])
	)
	if resp == null:
		return false
	return true


func get_entity(uuid):
	# Returns an Entity instance selected via UUID.
	var resp = await _send_request("entity/%s/" % uuid)
	if resp == null:
		return null
	return LittleDoodlesEntity.from_request_body(resp["entity"])


func search_entity(search_params):
	# Returns a list of Entity instances matching the given search parameters
	var resp = await _send_request("entity/search/?%s" % search_params)
	if resp == null:
		return null

	var entities = []
	for entitydef in resp["entities"]:
		entities.append(LittleDoodlesEntity.from_request_body(entitydef))
	return entities


func _send_request(endpoint, method = HTTPClient.METHOD_GET, body = ""):
	var headers = ["Content-Type: application/json"]
	if cookiejar:
		headers.append("Cookie: %s" % cookiejar.join("; "))

	request(api_url.path_join(endpoint), headers, method, body)

	var response = await request_completed
	if response[0] != 0:
		push_error("Request Error Occurred: %s" % response[0])
		return null
	
	# Handle cookie headers
	for header in response[2]:
		if header.to_lower().begins_with("set-cookie"):
			cookiejar.append(header.split(":", true, 1)[1].strip_edges().split("; ")[0])

	if response[1] != 200:
		push_error("Non-OK Response Code Received: %s" % response[1])
		return null

	var resp_body_str = response[3].get_string_from_utf8()
	var resp_body = null
	if resp_body_str != null && not resp_body_str.is_empty():
		resp_body = JSON.parse_string(resp_body_str)

	if resp_body != null and resp_body.get("result", "") == "failure":
		push_error(JSON.stringify(["errors"], "  "))
		return null

	return resp_body
