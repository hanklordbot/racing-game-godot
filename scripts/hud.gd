extends CanvasLayer

@onready var speed_label: Label = $Panel/Speed
@onready var mileage_label: Label = $Panel/Mileage
@onready var lap_label: Label = $Panel/Lap
@onready var rank_label: Label = $Panel/Rank
var wrong_way_label: Label

var player: Node3D
var tracker: Node

func _ready() -> void:
	player = get_node_or_null("../Player")
	tracker = get_node_or_null("../MileageTracker")
	# Create wrong-way warning label
	wrong_way_label = Label.new()
	wrong_way_label.text = "逆走！"
	wrong_way_label.add_theme_font_size_override("font_size", 48)
	wrong_way_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	wrong_way_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wrong_way_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	wrong_way_label.position = Vector2(540, 80)
	wrong_way_label.visible = false
	add_child(wrong_way_label)

func _process(_delta: float) -> void:
	if player == null or tracker == null: return
	var info = tracker.get_info(player)
	speed_label.text = "速度: %d km/h" % player.get_speed_kmh()
	mileage_label.text = "里程: %d m" % int(info.mileage)
	lap_label.text = "圈數: %d / %d" % [info.lap + 1, tracker.total_laps]
	rank_label.text = "名次: %d" % tracker.get_rank(player)
	if info.finished:
		lap_label.text = "完賽!"
	# Wrong way warning
	wrong_way_label.visible = player.is_wrong_way
