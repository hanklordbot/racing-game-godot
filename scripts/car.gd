extends CharacterBody3D

@export var max_speed := 30.0
@export var accel := 15.0
@export var brake_force := 25.0
@export var friction := 2.0
@export var turn_speed := 2.5
@export var handbrake_friction := 8.0

var speed := 0.0
var steer_input := 0.0

func _ready() -> void:
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
	velocity.y -= 9.8 * delta  # gravity
	move_and_slide()

func get_speed_kmh() -> float:
	return absf(speed) * 3.6
