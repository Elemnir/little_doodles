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
	# otherwise update it.
	pass

func get_entity(uuid):
	# Returns an Entity instance selected via UUID.
	pass

func search_entity(search_params):
	# Returns a list of Entity instances matching the given search parameters
	pass

func _send_request(endpoint, method = HTTPClient.METHOD_GET, body = ""):
	var headers = ["Content-Type: application/json"]
	if cookiejar:
		headers.append("Cookie: %s" % cookiejar.join("; "))

	request(api_url.path_join(endpoint), headers, method, body)

	var response = await request_completed
	if response[0] == 0:
		# Handle cookie headers
		for header in response[2]:
			if header.to_lower().begins_with("set-cookie"):
				cookiejar.append(header.split(":", true, 1)[1].strip_edges().split("; ")[0])

		var resp_body_str = response[3].get_string_from_utf8()
		var resp_body = null
		if resp_body_str != null && not resp_body_str.is_empty():
			resp_body = JSON.parse_string(resp_body_str)

		return {
			"resp_code": response[1],
			"resp_body": resp_body,
		}

	return {"resp_code": null, "resp_body": null}
