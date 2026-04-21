extends Node3D

var engine_player: AudioStreamPlayer3D
var brake_player: AudioStreamPlayer3D

func _ready() -> void:
	# Create engine sound placeholder (will use pitch modulation)
	engine_player = AudioStreamPlayer3D.new()
	engine_player.name = "Engine"
	add_child(engine_player)
	brake_player = AudioStreamPlayer3D.new()
	brake_player.name = "Brake"
	add_child(brake_player)

func update_engine(speed_ratio: float) -> void:
	# Pitch scales with speed: idle=0.8, max=2.0
	if engine_player.stream:
		engine_player.pitch_scale = 0.8 + speed_ratio * 1.2

func play_brake() -> void:
	pass  # placeholder

func play_collision() -> void:
	pass  # placeholder
