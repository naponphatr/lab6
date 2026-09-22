extends Node3D

## ทำให้ก้อนเมฆลอยเคลื่อนที่ไปมาเบาๆ รอบตำแหน่งเริ่มต้นของมัน

@export var move_distance: Vector3 = Vector3(6.0, 0.6, 4.0) # ระยะที่เมฆจะขยับไปมาในแต่ละแกน (X, Y, Z)
@export var move_speed: float = 0.15 # ความเร็วในการลอยไปมา (ค่ายิ่งน้อยยิ่งลอยช้า)
@export var rotate_speed: float = 0.0 # ถ้าอยากให้เมฆหมุนช้าๆ ด้วย ใส่ค่ามากกว่า 0

var _start_position: Vector3
var _time_offset: float

func _ready() -> void:
	_start_position = position
	# สุ่มจุดเริ่มต้นของแต่ละก้อนเมฆ ไม่ให้ลอยพร้อมกันเป๊ะๆ ดูเป็นธรรมชาติกว่า
	_time_offset = randf() * TAU

func _process(delta: float) -> void:
	var t: float = (Time.get_ticks_msec() / 1000.0) * move_speed + _time_offset
	var offset := Vector3(
		sin(t) * move_distance.x,
		sin(t * 1.3) * move_distance.y,
		cos(t * 0.8) * move_distance.z
	)
	position = _start_position + offset

	if rotate_speed != 0.0:
		rotate_y(rotate_speed * delta)
