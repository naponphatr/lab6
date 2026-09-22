extends Node3D

## ทำให้ดาวหมุนช้าๆ ลอยตัวเบาๆ และแสงกระพริบ (twinkle) เหมือนดาวส่องแสง

@export var spin_speed: float = 0.4          # ความเร็วในการหมุนรอบตัวเอง
@export var bob_height: float = 0.4          # ระยะลอยขึ้นลง
@export var bob_speed: float = 0.5           # ความเร็วในการลอยขึ้นลง
@export var twinkle_amount: float = 0.35     # สัดส่วนความแรงแสงที่กระพริบ (0-1)
@export var twinkle_speed: float = 1.6       # ความเร็วในการกระพริบ

@onready var _light: OmniLight3D = get_node_or_null("StarLight")

var _start_position: Vector3
var _time_offset: float
var _base_energy: float = 1.0

func _ready() -> void:
	_start_position = position
	_time_offset = randf() * TAU
	if _light:
		_base_energy = _light.light_energy

func _process(delta: float) -> void:
	var t: float = (Time.get_ticks_msec() / 1000.0) + _time_offset

	# ลอยขึ้นลงเบาๆ
	position = _start_position + Vector3(0, sin(t * bob_speed) * bob_height, 0)

	# หมุนรอบตัวเองช้าๆ
	rotate_y(spin_speed * delta)

	# แสงกระพริบแบบดาวจริง
	if _light:
		var flicker := 1.0 + sin(t * twinkle_speed) * twinkle_amount
		_light.light_energy = _base_energy * flicker
