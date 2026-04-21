extends Camera3D

@export var target_path: NodePath
@export var distance := 8.0
@export var height := 4.0
@export var smooth := 5.0

var target: Node3D

func _ready() -> void:
	if not target_path.is_empty():
		target = get_node_or_null(target_path)

func _physics_process(delta: float) -> void:
	if target == null: return
	var back = target.transform.basis.z.normalized()
	var desired = target.global_position + back * distance + Vector3.UP * height
	global_position = global_position.lerp(desired, smooth * delta)
	look_at(target.global_position + Vector3.UP * 1.0, Vector3.UP)
