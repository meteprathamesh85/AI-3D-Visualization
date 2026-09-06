class_name TaskVisual
extends Node3D

var task_data: Dictionary = {}
var marker: MeshInstance3D
var label: Label3D
var progress_bar: MeshInstance3D
var progress_material: StandardMaterial3D

func setup(data: Dictionary) -> void:
	task_data = data.duplicate(true)
	_build()
	update_data(data)

func _build() -> void:
	marker = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.2, 0.12, 0.55)
	marker.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.22, 0.35)
	marker.material_override = mat
	add_child(marker)

	progress_bar = MeshInstance3D.new()
	var bar := BoxMesh.new()
	bar.size = Vector3(1.0, 0.03, 0.18)
	progress_bar.mesh = bar
	progress_material = StandardMaterial3D.new()
	progress_material.albedo_color = Color(0.25, 0.85, 0.65)
	progress_bar.material_override = progress_material
	progress_bar.position.y = 0.08
	add_child(progress_bar)

	label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 18
	label.outline_size = 5
	label.position.y = 0.32
	add_child(label)

func update_data(data: Dictionary) -> void:
	for key in data:
		task_data[key] = data[key]
	var p:float = clampf(float(task_data.get("progress", 0.0)), 0.0, 1.0)
	label.text = "%s  %d%%" % [str(task_data.get("task_id", "task")), int(p * 100.0)]
	progress_bar.scale.x = max(p, 0.02)
