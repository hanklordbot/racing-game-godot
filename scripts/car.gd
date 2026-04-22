extends CharacterBody3D

@export var max_speed := 30.0
@export var accel := 15.0
@export var brake_force := 25.0
@export var friction := 2.0
@export var turn_speed := 2.5
@export var handbrake_friction := 8.0
@export var wall_speed_loss := 0.4  # lose 40% speed on wall hit
@export var max_reverse_angle := deg_to_rad(60.0)

var speed := 0.0
var steer_input := 0.0
var is_wrong_way := false

func _ready() -> void:
	# Ensure wall sliding works well
	floor_max_angle = deg_to_rad(60)
	wall_min_slide_angle = deg_to_rad(10)
	var tracker = get_node_or_null("../MileageTracker")
	if tracker: tracker.register(self)

func _physics_process(delta: float) -> void:
	var forward = -transform.basis.z
	# Input
	var throttle := 0.0
	if Input.is_action_pressed("accelerate"): throttle = 1.0
	elif Input.is_action_pressed("brake"): throttle = -0.5
	steer_input = 0.0
	if Input.is_action_pressed("steer_left"): steer_input = 1.0
	elif Input.is_action_pressed("steer_right"): steer_input = -1.0
	var braking = Input.is_action_pressed("handbrake")

	# Acceleration
	speed += throttle * accel * delta
	# Friction
	var fric = handbrake_friction if braking else friction
	speed *= (1.0 - fric * delta)
	speed = clampf(speed, -max_speed * 0.3, max_speed)

	# Steering (speed-dependent)
	if absf(speed) > 0.5:
		var turn_factor = clampf(absf(speed) / max_speed, 0.3, 1.0)
		rotation.y += steer_input * turn_speed * turn_factor * delta * signf(speed)

	# Apply velocity
	velocity = forward * speed
	velocity.y -= 9.8 * delta
	move_and_slide()

	# Wall collision: lose speed on slide
	if get_slide_collision_count() > 0:
		speed *= (1.0 - wall_speed_loss)

	# Anti-reverse: check heading vs track tangent
	_check_wrong_way()

func _check_wrong_way() -> void:
	var path = get_node_or_null("../Track/CenterLine")
	if path == null or path.curve == null:
		is_wrong_way = false; return
	var curve = path.curve
	var total = curve.get_baked_length()
	# Find closest offset
	var best_off := 0.0; var best_d := 999999.0
	for i in 40:
		var off = total * i / 40.0
		var p = path.to_global(curve.sample_baked(off))
		var d = global_position.distance_squared_to(p)
		if d < best_d: best_d = d; best_off = off
	# Get tangent at that point
	var sample_ahead = fmod(best_off + 1.0, total)
	var p0 = path.to_global(curve.sample_baked(best_off))
	var p1 = path.to_global(curve.sample_baked(sample_ahead))
	var tangent = (p1 - p0).normalized()
	tangent.y = 0
	var car_forward = (-transform.basis.z)
	car_forward.y = 0; car_forward = car_forward.normalized()
	var dot = car_forward.dot(tangent)
	var angle = acos(clampf(dot, -1.0, 1.0))
	is_wrong_way = angle > max_reverse_angle
	# Force correct heading if too far off
	if angle > max_reverse_angle and absf(speed) > 1.0:
		var cross = car_forward.cross(tangent).y
		rotation.y += signf(cross) * 1.5 * get_physics_process_delta_time()

func get_speed_kmh() -> float:
	return absf(speed) * 3.6
