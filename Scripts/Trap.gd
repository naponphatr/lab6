extends Area3D

# ----------------------------------------------------------------------------------- #
# -------------- TRAP SCRIPT - PATTERN COPIED FROM DeadZone.gd --------------------- #
# ----------------------------------------------------------------------------------- #
# วิธีใช้:
# 1. ลาก Trap.tscn มาวางในฉาก ตรงจุดที่ต้องการให้เป็นกับดัก (เช่น ใต้แพลตฟอร์ม, ข้างทาง)
# 2. ปรับขนาด/รูปร่างของ CollisionShape3D ใน Trap.tscn ให้พอดีกับโมเดลกับดักที่ใส่เพิ่ม
#    (เช่น โมเดลหนามจาก Poly Pizza ใส่เป็นลูกของ Trap.tscn ได้เลย)
# 3. เลือกโหมดการทำงานได้ 2 แบบผ่าน Inspector: "reset_only" หรือ "reset_and_lose_item"

# ---------- VARIABLES ---------- #

@export_category("Trap Settings")
@export_enum("reset_only", "reset_and_lose_item") var trap_mode: String = "reset_only"

@onready var spawn_position = %SpawnPosition
@onready var player = get_tree().get_first_node_in_group("Player")

# ---------- SIGNALS ---------- #

func _on_body_entered(body):
	# เช็คว่าเป็นผู้เล่นไหม (โครงสร้างเดียวกับ DeadZone.gd)
	if not body.is_in_group("Player"):
		return

	print("Trap: Player hit a trap!")

	# TODO: เล่นเสียง SFX ตอนโดนกับดัก เช่น AudioManager.hurt_sfx.play()
	# (ถ้าอยากเพิ่มเสียงเฉพาะ ให้ไปเพิ่ม stream ใน AudioManager.tscn ก่อน)

	match trap_mode:
		"reset_and_lose_item":
			# ตัวอย่าง: หักคะแนน/ไอเท็มไป 1 ชิ้น แต่ไม่ให้ติดลบ
			GameManager.score = max(0, GameManager.score - 1)
			player.global_position = spawn_position.global_position
		_:
			# ค่าเริ่มต้น: แค่เด้งกลับจุดเกิดเฉยๆ เหมือน DeadZone เดิม
			player.global_position = spawn_position.global_position
