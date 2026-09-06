extends Node3D

const AgentVisualScene := preload("res://scripts/agents/agent_visual.gd")
const TaskVisualScene := preload("res://scripts/tasks/task_visual.gd")
const MockEventGeneratorScene := preload("res://scripts/mock/mock_event_generator.gd")
const HttpEventSourceScene := preload("res://scripts/networking/http_event_source.gd")
const EventParserScene := preload("res://scripts/state/event_parser.gd")

var agents: Dictionary = {}
var tasks: Dictionary = {}
var event_lines: Array[String] = []
var selected_agent_id := ""
var mock_source: Node
var http_source: Node
var world_root: Node3D
var camera: Camera3D
var timeline: RichTextLabel
var status_panel: RichTextLabel
var connection_label: Label
var mode_label: Label
var endpoint_edit: LineEdit
var mock_button: Button
var pause_button: Button
var camera_angle := 0.0
var paused := false

func _ready() -> void:
	_build_world()
	_build_ui()
	_start_mock_mode()

func _process(delta: float) -> void:
	if paused:
		return

	camera_angle += delta * 0.04

	if camera:
		var radius := 18.0
		var camera_position := Vector3(
			sin(camera_angle) * radius,
			10.5,
			cos(camera_angle) * radius
		)

		camera.position = camera_position
		camera.look_at(Vector3(0.0, 0.0, 0.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_SPACE:
			_toggle_mock()
		elif event.physical_keycode == KEY_P:
			_toggle_pause()

func _build_world() -> void:
	world_root = Node3D.new()
	world_root.name = "VisualizationWorld"
	add_child(world_root)

	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(24, 16)
	ground.mesh = plane
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.055, 0.075, 0.12)
	ground_mat.roughness = 0.92
	ground.material_override = ground_mat
	ground.position.y = -0.08
	world_root.add_child(ground)

	_add_grid()

	camera = Camera3D.new()
	camera.position = Vector3(0.0, 10.5, 18.0)
	camera.current = true
	camera.fov = 52.0
	world_root.add_child(camera)
	camera.look_at(Vector3(0.0, 0.0, 0.0))

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-52, -28, 0)
	light.light_energy = 1.15
	light.shadow_enabled = false
	world_root.add_child(light)

	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 5, 2)
	fill.light_energy = 2.2
	fill.omni_range = 18.0
	world_root.add_child(fill)

	var title := Label3D.new()
	title.text = "AI VISUALIZATION GRID"
	title.font_size = 42
	title.outline_size = 10
	title.position = Vector3(0, 0.5, -6.2)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	world_root.add_child(title)

func _add_grid() -> void:
	var grid_mat := StandardMaterial3D.new()
	grid_mat.albedo_color = Color(0.12, 0.16, 0.24)
	grid_mat.emission_enabled = true
	grid_mat.emission = Color(0.025, 0.05, 0.1)

	for x in range(-10, 11):
		var line := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.025, 0.015, 15.0)
		line.mesh = box
		line.position = Vector3(float(x), 0.0, 0)
		line.material_override = grid_mat
		world_root.add_child(line)
	for z in range(-7, 8):
		var line2 := MeshInstance3D.new()
		var box2 := BoxMesh.new()
		box2.size = Vector3(20.0, 0.015, 0.025)
		line2.mesh = box2
		line2.position = Vector3(0, 0.01, float(z))
		line2.material_override = grid_mat
		world_root.add_child(line2)

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "UI"
	add_child(canvas)
	
	var viewport_size := get_viewport().get_visible_rect().size

	var top := PanelContainer.new()
	top.position = Vector2(18, 16)
	top.size = Vector2(viewport_size.x - 36.0, 72.0)
	canvas.add_child(top)
	var top_box := HBoxContainer.new()
	top_box.add_theme_constant_override("separation", 14)
	top.add_child(top_box)

	var heading := Label.new()
	heading.text = "PROJECT 1  •  3D AI VISUALIZATION"
	heading.add_theme_font_size_override("font_size", 22)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_box.add_child(heading)

	mode_label = Label.new()
	mode_label.text = "MODE: MOCK"
	mode_label.add_theme_font_size_override("font_size", 16)
	top_box.add_child(mode_label)

	connection_label = Label.new()
	connection_label.text = "● MOCK CONNECTED"
	connection_label.add_theme_font_size_override("font_size", 16)
	top_box.add_child(connection_label)

	mock_button = Button.new()
	mock_button.text = "Pause Mock"
	mock_button.pressed.connect(_toggle_mock)
	top_box.add_child(mock_button)

	pause_button = Button.new()
	pause_button.text = "Pause UI"
	pause_button.pressed.connect(_toggle_pause)
	top_box.add_child(pause_button)

	var right := PanelContainer.new()
	right.position = Vector2(viewport_size.x - 348.0, 104.0)
	right.size = Vector2(330.0, viewport_size.y - 122.0)
	canvas.add_child(right)
	var right_v := VBoxContainer.new()
	right_v.add_theme_constant_override("separation", 8)
	right.add_child(right_v)

	var status_title := Label.new()
	status_title.text = "SELECTED AGENT"
	status_title.add_theme_font_size_override("font_size", 18)
	right_v.add_child(status_title)

	status_panel = RichTextLabel.new()
	status_panel.bbcode_enabled = true
	status_panel.fit_content = true
	status_panel.custom_minimum_size = Vector2(300, 180)
	status_panel.text = "Click an agent in the 3D grid."
	right_v.add_child(status_panel)

	var sep := HSeparator.new()
	right_v.add_child(sep)

	var net_title := Label.new()
	net_title.text = "OPTIONAL HTTP SOURCE"
	net_title.add_theme_font_size_override("font_size", 16)
	right_v.add_child(net_title)

	endpoint_edit = LineEdit.new()
	endpoint_edit.placeholder_text = "https://example.com/events.json"
	endpoint_edit.text = ""
	right_v.add_child(endpoint_edit)

	var connect_btn := Button.new()
	connect_btn.text = "Connect HTTP Polling"
	connect_btn.pressed.connect(_connect_http)
	right_v.add_child(connect_btn)

	var mock_mode_btn := Button.new()
	mock_mode_btn.text = "Return to Mock Mode"
	mock_mode_btn.pressed.connect(_start_mock_mode)
	right_v.add_child(mock_mode_btn)

	var help := Label.new()
	help.text = """Space: mock on/off
		P: pause UI updates
		Click an agent to inspect"""
	help.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8))
	right_v.add_child(help)

	var bottom := PanelContainer.new()
	bottom.position = Vector2(18.0, viewport_size.y - 202.0)
	bottom.size = Vector2(viewport_size.x - 384.0, 184.0)
	canvas.add_child(bottom)
	var bottom_v := VBoxContainer.new()
	bottom.add_child(bottom_v)

	var event_title := Label.new()
	event_title.text = "EVENT TIMELINE"
	event_title.add_theme_font_size_override("font_size", 18)
	bottom_v.add_child(event_title)

	timeline = RichTextLabel.new()
	timeline.bbcode_enabled = true
	timeline.scroll_following = true
	timeline.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_v.add_child(timeline)

func _start_mock_mode() -> void:
	if is_instance_valid(http_source):
		http_source.stop()
	if is_instance_valid(mock_source):
		mock_source.queue_free()
	mock_source = MockEventGeneratorScene.new()
	add_child(mock_source)
	mock_source.event_generated.connect(_handle_event)
	mode_label.text = "MODE: MOCK"
	connection_label.text = "● MOCK CONNECTED"
	mock_button.text = "Pause Mock"

func _toggle_mock() -> void:
	if not is_instance_valid(mock_source):
		_start_mock_mode()
		return
	var running := not bool(mock_source.running)
	mock_source.set_running(running)
	mock_button.text = "Pause Mock" if running else "Resume Mock"
	connection_label.text = "● MOCK CONNECTED" if running else "● MOCK PAUSED"

func _toggle_pause() -> void:
	paused = not paused
	pause_button.text = "Resume UI" if paused else "Pause UI"

func _connect_http() -> void:
	var url := endpoint_edit.text.strip_edges()
	if url == "":
		connection_label.text = "● ENTER AN ENDPOINT"
		return
	if is_instance_valid(mock_source):
		mock_source.set_running(false)
	if not is_instance_valid(http_source):
		http_source = HttpEventSourceScene.new()
		add_child(http_source)
		http_source.event_received.connect(_handle_event)
		http_source.source_status.connect(_on_source_status)
	http_source.start(url, 3.0)
	mode_label.text = "MODE: HTTP POLLING"

func _on_source_status(message: String) -> void:
	connection_label.text = "● " + message.to_upper()

func _handle_event(event: Dictionary) -> void:
	var validation := EventParserScene.validate_event(event)
	if not validation.valid:
		_append_event("system.warning", "Rejected malformed event: " + ", ".join(validation.errors), "high")
		return

	var event_type := str(event.get("event", "unknown"))
	_append_event(event_type, _event_summary(event), str(event.get("importance", "normal")))

	match event_type:
		"agent.status", "agent.created", "agent.activated", "agent.completed", "agent.sleeping":
			_apply_agent_event(event)
		"task.created", "task.progress", "task.completed":
			_apply_task_event(event)
		"memory.saved", "lesson.candidate", "lesson.verified":
			_append_event("learning", str(event.get("message", "Learning event received")), "normal")
		"system.warning", "system.error":
			_on_source_status(str(event.get("message", event_type)))
		_:
			pass

func _apply_agent_event(event: Dictionary) -> void:
	var id := str(event.get("agent_id", "unknown"))
	if not agents.has(id):
		var agent := AgentVisualScene.new()
		agent.position = _agent_position(agents.size())
		agent.selected.connect(_on_agent_selected)
		world_root.add_child(agent)
		agents[id] = agent
		agent.setup(event)
	else:
		agents[id].update_data(event)

	if event.has("task_id"):
		_apply_task_event(event)

func _apply_task_event(event: Dictionary) -> void:
	var id := str(event.get("task_id", ""))
	if id == "":
		return
	if not tasks.has(id):
		var task := TaskVisualScene.new()
		task.position = _task_position(tasks.size())
		world_root.add_child(task)
		tasks[id] = task
		task.setup(event)
	else:
		tasks[id].update_data(event)

func _agent_position(index: int) -> Vector3:
	var positions := [
		Vector3(-6, 0.85, -2.5),
		Vector3(-3, 0.85, 1.2),
		Vector3(0, 0.85, -1.2),
		Vector3(3, 0.85, 1.2),
		Vector3(6, 0.85, -2.5)
	]
	return positions[index % positions.size()]

func _task_position(index: int) -> Vector3:
	var positions := [
		Vector3(-6, 0.15, -4.2),
		Vector3(-3, 0.15, 3.0),
		Vector3(0, 0.15, -4.2),
		Vector3(3, 0.15, 3.0),
		Vector3(6, 0.15, -4.2)
	]
	return positions[index % positions.size()]

func _on_agent_selected(data: Dictionary) -> void:
	selected_agent_id = str(data.get("agent_id", ""))
	status_panel.text = "[b]%s[/b]\nID: %s\nState: %s\nTask: %s\nProgress: %d%%\nAction: %s\nMessage: %s\nImportance: %s\nTimestamp: %s" % [
		str(data.get("role", "Agent")),
		selected_agent_id,
		str(data.get("state", "unknown")),
		str(data.get("task_id", "none")),
		int(float(data.get("progress", 0.0)) * 100.0),
		str(data.get("current_action", "—")),
		str(data.get("message", "—")),
		str(data.get("importance", "normal")),
		str(data.get("timestamp", "—"))
	]

func _event_summary(event: Dictionary) -> String:
	if event.has("agent_id"):
		return "%s → %s (%d%%) %s" % [
			str(event.get("agent_id")),
			str(event.get("state", event.get("event", ""))),
			int(float(event.get("progress", 0.0)) * 100.0),
			str(event.get("message", ""))
		]
	return str(event.get("message", event.get("task_id", event.get("event", ""))))

func _append_event(event_type: String, summary: String, importance: String) -> void:
	var stamp := Time.get_time_string_from_system()
	var line := "[color=#8b96aa]%s[/color]  [b]%s[/b]  %s" % [stamp, event_type, summary]
	if importance == "high":
		line = "[color=#ff8c8c]" + line + "[/color]"
	event_lines.push_front(line)
	if event_lines.size() > 12:
		event_lines.pop_back()
	if timeline:
		timeline.text = "\n".join(event_lines)
