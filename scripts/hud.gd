extends CanvasLayer

@onready var speed_label: Label = $Panel/Speed
@onready var mileage_label: Label = $Panel/Mileage
@onready var lap_label: Label = $Panel/Lap
@onready var rank_label: Label = $Panel/Rank

var player: Node3D
var tracker: Node

func _ready() -> void:
	player = get_node_or_null("../Player")
	tracker = get_node_or_null("../MileageTracker")

func _process(_delta: float) -> void:
	if player == null or tracker == null: return
	var info = tracker.get_info(player)
	speed_label.text = "速度: %d km/h" % player.get_speed_kmh()
	mileage_label.text = "里程: %d m" % int(info.mileage)
	lap_label.text = "圈數: %d / %d" % [info.lap + 1, tracker.total_laps]
	rank_label.text = "名次: %d" % tracker.get_rank(player)
	if info.finished:
		lap_label.text = "完賽!"
