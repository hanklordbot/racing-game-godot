extends CanvasLayer

# Exposed to car.gd
var touch_steer := 0.0  # -1 left, +1 right
var touch_throttle := false
var touch_brake := false

func _ready() -> void:
	var left_btn = _make_btn("◀", Vector2(20, -100), _on_left_down, _on_left_up)
	var right_btn = _make_btn("▶", Vector2(120, -100), _on_right_down, _on_right_up)
	var gas_btn = _make_btn("▲", Vector2(-120, -100), _on_gas_down, _on_gas_up)
	var brake_btn = _make_btn("■", Vector2(-220, -100), _on_brake_down, _on_brake_up)
	# Anchor right-side buttons to right
	gas_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	brake_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)

func _make_btn(text: String, offset: Vector2, down: Callable, up: Callable) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(90, 90)
	btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	btn.position = offset
	btn.add_theme_font_size_override("font_size", 36)
	# Semi-transparent style
	var sb_normal = StyleBoxFlat.new()
	sb_normal.bg_color = Color(1, 1, 1, 0.3)
	sb_normal.set_corner_radius_all(12)
	var sb_pressed = StyleBoxFlat.new()
	sb_pressed.bg_color = Color(1, 1, 1, 0.6)
	sb_pressed.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", sb_normal)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	btn.add_theme_stylebox_override("hover", sb_normal)
	btn.add_theme_color_override("font_color", Color(0, 0, 0, 0.8))
	btn.button_down.connect(down)
	btn.button_up.connect(up)
	add_child(btn)
	return btn

func _on_left_down() -> void: touch_steer = 1.0
func _on_left_up() -> void: if touch_steer > 0: touch_steer = 0.0
func _on_right_down() -> void: touch_steer = -1.0
func _on_right_up() -> void: if touch_steer < 0: touch_steer = 0.0
func _on_gas_down() -> void: touch_throttle = true
func _on_gas_up() -> void: touch_throttle = false
func _on_brake_down() -> void: touch_brake = true
func _on_brake_up() -> void: touch_brake = false
