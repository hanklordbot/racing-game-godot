extends Node

@export var total_laps := 3

var path: Path3D
var trackers: Dictionary = {}  # node_path -> {offset, mileage, lap, finished}

func _ready() -> void:
	path = get_node_or_null("../Track/CenterLine")

func register(car: Node3D) -> void:
	trackers[car.get_path()] = {offset=0.0, mileage=0.0, lap=0, finished=false}

func _physics_process(_delta: float) -> void:
	if path == null or path.curve == null: return
	var curve = path.curve
	var total = curve.get_baked_length()
	for key in trackers:
		var car = get_node_or_null(key)
		if car == null: continue
		var t = trackers[key]
		if t.finished: continue
		var new_off = _closest_offset(curve, car.global_position, total)
		var diff = new_off - t.offset
		# Handle wrap-around
		if diff < -total * 0.5: diff += total
		elif diff > total * 0.5: diff -= total
		if diff > 0:
			t.mileage += diff
		t.offset = new_off
		# Lap detection: crossed start (offset near 0 from high value)
		var lap_threshold = total * 0.95
		if t.mileage > total * (t.lap + 1) * 0.9 and t.offset < total * 0.1:
			t.lap += 1
			if t.lap >= total_laps:
				t.finished = true

func get_info(car: Node3D) -> Dictionary:
	return trackers.get(car.get_path(), {offset=0.0, mileage=0.0, lap=0, finished=false})

func get_rank(car: Node3D) -> int:
	var my = get_info(car)
	var rank = 1
	for key in trackers:
		var other = trackers[key]
		if other.mileage > my.mileage: rank += 1
	return rank

func _closest_offset(curve: Curve3D, pos: Vector3, total: float) -> float:
	var best_off := 0.0; var best_dist := 999999.0
	var steps := 60
	for i in steps:
		var off = total * i / float(steps)
		var p = path.to_global(curve.sample_baked(off))
		var d = pos.distance_squared_to(p)
		if d < best_dist: best_dist = d; best_off = off
	return best_off
