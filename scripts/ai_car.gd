extends CharacterBody3D

@export var max_speed := 25.0
@export var accel := 12.0
@export var friction := 2.0
@export var turn_speed := 3.0
@export var look_ahead := 8.0

var speed := 0.0
var path: Path3D
var path_offset := 0.0

func _ready() -> void:
	path = get_node_or_null("../Track/CenterLine")
	var tracker = get_node_or_null("../MileageTracker")
	if tracker: tracker.register(self)

func _physics_process(delta: float) -> void:
	if path == null or path.curve == null: return
	var curve = path.curve
	var total_len = curve.get_baked_length()

	# Find target point ahead on path
	path_offset = _closest_offset(curve, global_position, total_len)
	var target_offset = fmod(path_offset + look_ahead, total_len)
	var target_pos = path.to_global(curve.sample_baked(target_offset))
	target_pos.y = global_position.y

	# Steer toward target
	var to_target = (target_pos - global_position).normalized()
	var forward = -transform.basis.z
	var cross = forward.cross(to_target).y
	var dot = forward.dot(to_target)

	# Speed control: slow in curves
	var curve_factor = clampf(dot, 0.3, 1.0)
	speed += accel * curve_factor * delta
	speed *= (1.0 - friction * delta)
	speed = clampf(speed, 0.0, max_speed * curve_factor)

	# Turn
	rotation.y += cross * turn_speed * delta

	velocity = -transform.basis.z * speed
	velocity.y -= 9.8 * delta
	move_and_slide()

func _closest_offset(curve: Curve3D, pos: Vector3, total: float) -> float:
	var best_off := 0.0
	var best_dist := 999999.0
	var steps := 40
	for i in steps:
		var off = total * i / float(steps)
		var p = path.to_global(curve.sample_baked(off))
		var d = pos.distance_squared_to(p)
		if d < best_dist: best_dist = d; best_off = off
	return best_off

func get_speed_kmh() -> float:
	return absf(speed) * 3.6
