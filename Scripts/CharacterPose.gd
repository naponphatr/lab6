extends Node3D
## แนบสคริปต์นี้กับตัวละคร (instance ของ Rumba Dancing.fbx) แต่ละตัว
## สคริปต์จะ:
## 1. โหลด AnimationLibrary (Locomotion-Library / Melee-Library--OLD) เข้า AnimationPlayer ให้อัตโนมัติ
## 2. ค้นหาท่าที่ชื่อมีคำใน pose_keywords แล้วเล่นแบบ loop
## 3. อัปเดตป้ายชื่อ (Label3D ชื่อ "PoseLabel" ถ้ามี) ให้โชว์ท่าที่กำลังเล่นอยู่

@export var pose_keywords: String = "idle,stand"  # ใส่หลายคำคั่นด้วย , เรียงจากที่อยากได้ก่อน
@export var thai_label: String = "ยืน"
@export var use_default_library_as_fallback: bool = false  # true เฉพาะตัวที่จะใช้ท่าที่ติดมากับ fbx เอง (เช่น ท่าเต้น)

var anim_player: AnimationPlayer
var label3d: Label3D

const EXTRA_LIBRARIES := {
	"Locomotion-Library": "res://cat/Locomotion-Library.res",
	"Melee-Library--OLD": "res://cat/Melee-Library--OLD.res",
}


func _ready() -> void:
	anim_player = find_child("AnimationPlayer", true, false) as AnimationPlayer
	label3d = find_child("PoseLabel", true, false) as Label3D

	if anim_player == null:
		push_warning("[%s] ไม่พบ AnimationPlayer ในตัวละครนี้" % name)
		return

	_load_extra_libraries()

	var chosen := _find_animation()
	if chosen == "":
		push_warning(
			"[%s] หาไม่ท่าที่ตรงกับคำว่า '%s' — ท่าทั้งหมดที่มีคือ: %s"
			% [name, pose_keywords, anim_player.get_animation_list()]
		)
		return

	var anim: Animation = anim_player.get_animation(chosen)
	if anim:
		anim.loop_mode = Animation.LOOP_LINEAR  # บังคับให้ loop

	anim_player.play(chosen)
	_update_label(chosen)


func _load_extra_libraries() -> void:
	for lib_name in EXTRA_LIBRARIES.keys():
		if anim_player.has_animation_library(lib_name):
			continue
		var path: String = EXTRA_LIBRARIES[lib_name]
		if ResourceLoader.exists(path):
			var lib: AnimationLibrary = load(path)
			if lib:
				anim_player.add_animation_library(lib_name, lib)


func _find_animation() -> String:
	var all_anims := anim_player.get_animation_list()
	for raw_kw in pose_keywords.to_lower().split(","):
		var kw := raw_kw.strip_edges()
		if kw == "":
			continue
		for anim_name in all_anims:
			if anim_name.to_lower().find(kw) != -1:
				return anim_name

	if use_default_library_as_fallback:
		for anim_name in all_anims:
			if not anim_name.contains("/"):  # แปลว่าเป็นแอนิเมชันที่ติดมากับตัว fbx เอง ไม่ได้มาจากไลบรารีแยก
				return anim_name

	return ""


func _update_label(anim_name: String) -> void:
	if label3d:
		label3d.text = "%s\n(%s)" % [thai_label, anim_name.get_file()]
