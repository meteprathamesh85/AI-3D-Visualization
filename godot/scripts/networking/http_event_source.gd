class_name HttpEventSource
extends Node

signal event_received(event: Dictionary)
signal source_status(message: String)

var endpoint := ""
var poll_interval := 3.0
var elapsed := 0.0
var active := false
var request: HTTPRequest

func _ready() -> void:
	request = HTTPRequest.new()
	request.timeout = 5.0
	add_child(request)
	request.request_completed.connect(_on_request_completed)

func start(url: String, seconds := 3.0) -> void:
	endpoint = url.strip_edges()
	poll_interval = max(seconds, 1.0)
	active = endpoint != ""
	elapsed = poll_interval
	source_status.emit("HTTP source ready" if active else "HTTP source disabled")

func stop() -> void:
	active = false
	source_status.emit("HTTP source stopped")

func _process(delta: float) -> void:
	if not active:
		return

	var status := request.get_http_client_status()

	if status == HTTPClient.STATUS_DISCONNECTED:
		elapsed += delta

		if elapsed >= poll_interval:
			elapsed = 0.0

			var err := request.request(endpoint)
			if err != OK:
				source_status.emit("HTTP request error: %s" % err)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		source_status.emit("HTTP disconnected / request failed")
		return
	if response_code < 200 or response_code >= 300:
		source_status.emit("HTTP status %d" % response_code)
		return
	var text := body.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	if parsed is Array:
		for item in parsed:
			if item is Dictionary:
				event_received.emit(item)
	elif parsed is Dictionary:
		event_received.emit(parsed)
	else:
		source_status.emit("Malformed JSON response")
