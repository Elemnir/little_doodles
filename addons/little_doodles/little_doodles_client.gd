@icon("res://addons/little_doodles/little_doodles_client.svg")
class_name LittleDoodlesClient extends HTTPRequest
## Client class for interacting with a LittleDoodles Server.
##

## LittleDoodles API Endpoints 
const Endpoints = {
	USER_AUTH = "/game/user/auth/",
	USER_CREATE = "/game/user/add/",
	ENTITY_SEARCH = "/game/entity/search/?%s",
	ENTITY_CREATE = "/game/entity/add/",
	ENTITY_GET = "/game/entity/%s/"
}

## The URL including protocol and domain name where the LittleDoodlesServer
## is running. Supports HTTP or HTTPS, as well as arbitrary ports.
@export var api_url = "https://example.com"

var _cookiejar := PackedStringArray()


## Register a new user account with the server. Also logs the user in. Returns
## true if successful
func create_user(username: String, password: String) -> bool:
	var resp = await _send_request(Endpoints.USER_CREATE)
	if resp == null:
		return false
		
	var csrf_header = PackedStringArray(["X-CSRFToken: %s" % resp["csrf_token"]])
	resp = await _send_request(
		Endpoints.USER_CREATE,
		HTTPClient.METHOD_POST,
		csrf_header,
		JSON.stringify({
			"csrfmiddlewaretoken": resp["csrf_token"],
			"username": username,
			"password1": password,
			"password2": password,
		})
	)
	return resp != null


## Log an existing user into the server. Returns true is successful
func auth_user(username: String, password: String) -> bool:
	var resp = await _send_request(Endpoints.USER_AUTH)
	if resp == null:
		return false
	var csrf_header = PackedStringArray(["X-CSRFToken: %s" % resp["csrf_token"]])
	resp = await _send_request(
		Endpoints.USER_AUTH, 
		HTTPClient.METHOD_POST,
		csrf_header,		
		JSON.stringify({
			"csrfmiddlewaretoken": resp["csrf_token"],
			"username": username,
			"password": password,
		})
	)
	return resp != null

## Create the Entity on the server if it doesn't already have a UUID, otherwise
## update it. Returns true if the save completed successfully
func save_entity(entity: LittleDoodlesEntity) -> bool:
	var endpoint = Endpoints.ENTITY_CREATE if entity.uuid == null else Endpoints.ENTITY_GET % entity.uuid
	var resp = await _send_request(endpoint)
	if resp == null:
		return false
	var csrf_header = PackedStringArray(["X-CSRFToken: %s" % resp["csrf_token"]])
	resp = await _send_request(
		endpoint, HTTPClient.METHOD_POST, csrf_header, entity.as_request_body()
	)
	return resp != null


## Returns an Entity instance selected via UUID.
func get_entity(uuid: String):
	var resp = await _send_request(Endpoints.ENTITY_GET % uuid)
	if resp == null:
		return null
	return LittleDoodlesEntity.from_request_body(resp["entity"])


## Returns a list of Entity instances matching the given search parameters
## which should be given as a URI-encoded String of GET parameters. Supports
## most Django filter kwarg expressions.
func search_entities(search_params: String):
	var resp = await _send_request(Endpoints.ENTITY_SEARCH % search_params)
	if resp == null:
		return null

	var entities = []
	for entitydef in resp["entities"]:
		entities.append(LittleDoodlesEntity.from_request_body(entitydef))
	return entities


func _send_request(endpoint, method = HTTPClient.METHOD_GET, extra_headers: PackedStringArray = [], body: String = ""):
	var request_headers = PackedStringArray(["Content-Type: application/json"])
	request_headers.append_array(extra_headers)
	if _cookiejar:
		request_headers.append("Cookie: %s" % "; ".join(_cookiejar))

	request(api_url.path_join(endpoint), request_headers, method, body)

	var response = await request_completed
	var response_result: int = response[0]
	var response_code: int = response[1]
	var response_headers: PackedStringArray = response[2]
	var response_body: PackedByteArray = response[3]
	
	if response_result != RESULT_SUCCESS:
		push_error("Request Error Occurred: %s" % response_result)
		return null
	
	# Handle cookie headers
	for header in response_headers:
		if header.to_lower().begins_with("set-cookie"):
			_cookiejar.append(header.split(":", true, 1)[1].strip_edges().split("; ")[0])

	if response_code != 200:
		push_error("Non-OK Response Code Received: %s" % response_code)
		return null

	var resp_body_str = response_body.get_string_from_utf8()
	var resp_body = null
	if resp_body_str != null && not resp_body_str.is_empty():
		resp_body = JSON.parse_string(resp_body_str)

	if resp_body != null and resp_body.get("result", "") == "failure":
		push_error(JSON.stringify(resp_body["errors"]))
		return null

	return resp_body
