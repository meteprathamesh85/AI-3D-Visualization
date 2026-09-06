class_name AgentVisual
extends Node3D

const AGENT_MODEL: PackedScene = preload("res://assets/agents/agent_visual.glb")

signal selected(agent_data: Dictionary)

var agent_data: Dictionary = {}

var model_instance: Node3D
var body_material: StandardMaterial3D
var ring_material: StandardMaterial3D

var label: Label3D
var status_label: Label3D

var pulse_time: float = 0.0


func setup(data: Dictionary) -> void:
	agent_data = data.duplicate(true)
	_build_visual()
	apply_state(str(data.get("state", "idle")))


func _build_visual() -> void:
	if model_instance:
		return

	# -----------------------------------------------------
	# Collision
	# -----------------------------------------------------

	var collision_body := StaticBody3D.new()
	collision_body.input_ray_pickable = true
	collision_body.input_event.connect(_on_input_event)
	add_child(collision_body)

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.75
	shape.shape = sphere
	shape.position.y = 0.9
	collision_body.add_child(shape)

	# -----------------------------------------------------
	# Blender model
	# -----------------------------------------------------

	model_instance = AGENT_MODEL.instantiate()
	model_instance.name = "BlenderAgentModel"
	collision_body.add_child(model_instance)

	# -----------------------------------------------------
	# Find Blender materials
	# -----------------------------------------------------

	var body_node := model_instance.find_child(
		"AgentBody",
		true,
		false
	)

	if body_node is MeshInstance3D:
		body_material = StandardMaterial3D.new()
		body_material.metallic = 0.2
		body_material.roughness = 0.65
		body_node.material_override = body_material

	var ring_node := model_instance.find_child(
		"AgentStatusRing",
		true,
		false
	)

	if ring_node is MeshInstance3D:
		ring_material = StandardMaterial3D.new()
		ring_material.metallic = 0.3
		ring_material.roughness = 0.35
		ring_node.material_override = ring_material

	# -----------------------------------------------------
	# Agent role label
	# -----------------------------------------------------

	label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 32
	label.outline_size = 8
	label.modulate = Color(0.9, 0.95, 1.0)
	label.position.y = 2.45
	label.text = str(
		agent_data.get("role", "Agent")
	)
	add_child(label)

	# -----------------------------------------------------
	# Status label
	# -----------------------------------------------------

	status_label = Label3D.new()
	status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	status_label.font_size = 22
	status_label.outline_size = 6
	status_label.position.y = 2.12
	add_child(status_label)


func apply_state(new_state: String) -> void:
	agent_data["state"] = new_state

	var c: Color = _state_color(new_state)

	# -----------------------------------------------------
	# Blender body
	# -----------------------------------------------------

	if body_material:
		body_material.albedo_color = c
		body_material.emission_enabled = true
		body_material.emission = c * 0.25

	# -----------------------------------------------------
	# Blender status ring
	# -----------------------------------------------------

	if ring_material:
		ring_material.albedo_color = c
		ring_material.emission_enabled = true
		ring_material.emission = c * 0.65

	# -----------------------------------------------------
	# Status text
	# -----------------------------------------------------

	if status_label:
		status_label.text = new_state.to_upper()
		status_label.modulate = c


func update_data(data: Dictionary) -> void:
	for key in data:
		agent_data[key] = data[key]

	if label:
		label.text = str(
			agent_data.get(
				"role",
				agent_data.get("agent_id", "Agent")
			)
		)

	apply_state(
		str(agent_data.get("state", "idle"))
	)


func _process(delta: float) -> void:
	var state := str(
		agent_data.get("state", "idle")
	)

	if state in [
		"working",
		"testing",
		"teaching",
        "waiting"
	]:
		pulse_time += delta

		var scale_factor: float = (
			1.0 + sin(pulse_time * 4.0) * 0.035
		)

		scale = Vector3.ONE * scale_factor

	else:
		scale = scale.lerp(
			Vector3.ONE,
			min(delta * 8.0, 1.0)
		)


func _on_input_event(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:

	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		selected.emit(agent_data)
		get_viewport().set_input_as_handled()


func _state_color(state: String) -> Color:
	match state:
		"working", "testing", "teaching":
			return Color(0.2, 0.75, 1.0)

		"waiting":
			return Color(1.0, 0.72, 0.25)

		"error":
			return Color(1.0, 0.25, 0.28)

		"sleeping":
			return Color(0.42, 0.48, 0.62)

		"completed":
			return Color(0.35, 0.9, 0.52)

		_:
			return Color(0.58, 0.68, 0.86)
