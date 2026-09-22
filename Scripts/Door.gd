extends Area3D

# ----------------------------------------------------------------------------------- #
# -------------- DOOR / GOAL SCRIPT - PATTERN COPIED FROM DeadZone.gd -------------- #
# ----------------------------------------------------------------------------------- #
# วิธีใช้:
# 1. ลาก Door.tscn มาวางในฉาก
# 2. ตั้งค่า "Required Items" ใน Inspector ให้ตรงกับจำนวนไอเท็มทั้งหมดในฉากนั้น
# 3. ตั้งค่า "Next Scene Path" เป็น path ของฉากถัดไป เช่น res://Scenes/level_2.tscn
#    (ถ้าเป็นฉากสุดท้าย จะปล่อยว่างไว้ก็ได้ แล้วเปลี่ยนเป็นแสดงหน้าจอ "You Win" แทน)

# ---------- VARIABLES ---------- #

@export_category("Door Settings")
@export var required_items: int = 5          # จำนวนไอเท็มที่ต้องเก็บให้ครบก่อนถึงจะผ่านประตูได้
@export var next_scene_path: String = ""     # path ของฉากถัดไป เช่น "res://Scenes/level_2.tscn"

# ---------- SIGNALS ---------- #

func _on_body_entered(body):
	# เช็คว่าเป็นผู้เล่นไหม
	if not body.is_in_group("Player"):
		return

	# เช็คว่าเก็บไอเท็มครบตามที่กำหนดหรือยัง (ใช้ GameManager.score ที่มีอยู่แล้วในโปรเจกต์)
	if GameManager.score >= required_items:
		print("Door: Player collected enough items! Going to next scene...")
		if next_scene_path != "":
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("Door: No next_scene_path set. This might be the final level!")
			# TODO: ตรงนี้สามารถใส่โค้ดแสดงหน้าจอ "You Win" แทนได้
	else:
		var missing = required_items - GameManager.score
		print("Door: Locked! Need %d more item(s)." % missing)
		# TODO: ตรงนี้สามารถเล่นเสียง "ประตูล็อก" หรือแสดงข้อความบนจอได้
