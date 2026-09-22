# ----------------------------------------------------------------------------------- #
# -------------- FEEL FREE TO USE IN ANY PROJECT, COMMERCIAL OR NON-COMMERCIAL ------ #
# ---------------------- 3D PLATFORMER CONTROLLER BY SD STUDIOS --------------------- #
# ---------------------------- ATTRIBUTION NOT REQUIRED ----------------------------- #
# ----------------------------------------------------------------------------------- #

extends CharacterBody3D

# ---------- VARIABLES ---------- #

@export_category("Player Properties")
@export var move_speed : float = 6
@export var jump_force : float = 5.5
@export var follow_lerp_factor : float = 4
@export var jump_limit : int = 3

@export_group("Game Juice")
@export var jumpStretchSize := Vector3(0.8, 1.2, 0.8)

# Booleans
var is_grounded = false

# Jump tracking
var jumps_used : int = 0

# Onready Variables
@onready var model = $Doraemon
@onready var animation : AnimationPlayer = model.find_child("AnimationPlayer", true, false)
@onready var spring_arm = %Gimbal

@onready var particle_trail = $ParticleTrail
@onready var footsteps = $Footsteps

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

# Cache of resolved animation names, since some imported models (like Mixamo/
# Quaternius rigs) name their clips with a long prefix, e.g.
# "CharacterArmature|CharacterArmature|Idle" instead of just "Idle".
var _anim_name_cache := {}

const PLAYER_ANIMATION_LIBRARIES := {
	"Locomotion-Library": "res://cat/Locomotion-Library.res",
	"Melee-Library--OLD": "res://cat/Melee-Library--OLD.res",
}

func _ready() -> void:
	# Doraemon/Rumba Dancing.fbx contains the character rig.  The locomotion
	# clips used by the Lab 5 controller live in separate AnimationLibraries.
	if animation == null:
		push_error("Doraemon Player: AnimationPlayer not found")
		return
	for library_name in PLAYER_ANIMATION_LIBRARIES:
		if animation.has_animation_library(library_name):
			continue
		var library_path: String = PLAYER_ANIMATION_LIBRARIES[library_name]
		if ResourceLoader.exists(library_path):
			var library := load(library_path) as AnimationLibrary
			if library:
				animation.add_animation_library(library_name, library)

# Finds the real clip name in the AnimationPlayer that matches a short name
# like "Idle", "Run", "Jump" — matching exactly, or as a suffix after "|".
func resolve_anim(short_name: String) -> String:
	if _anim_name_cache.has(short_name):
		return _anim_name_cache[short_name]
	var resolved := ""
	if animation.has_animation(short_name):
		resolved = short_name
	else:
		var wanted := short_name.to_lower()
		for anim_name in animation.get_animation_list():
			var lowered := anim_name.to_lower()
			if lowered == wanted or lowered.ends_with("|" + wanted) or lowered.ends_with("/" + wanted) or lowered.find(wanted) != -1:
				resolved = anim_name
				break
	_anim_name_cache[short_name] = resolved
	return resolved

# Plays an animation by its short name, resolving the real clip name first.
func play_anim(short_name: String, blend := -1.0, custom_speed := 1.0):
	var resolved = resolve_anim(short_name)
	if resolved == "":
		return
	animation.play(resolved, blend, custom_speed)

# ---------- FUNCTIONS ---------- #

func _process(delta):
	player_animations()
	get_input(delta)
	
	# Smoothly follow player's position
	spring_arm.position = lerp(spring_arm.position, position, delta * follow_lerp_factor)
	
	# Player Rotation
	if is_moving():
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 12)
	
	# Check if player is grounded or not
	is_grounded = true if is_on_floor() else false
	
	# Handle Jumping - reset jump counter whenever we touch the ground
	if is_grounded:
		jumps_used = 0
	
	if Input.is_action_just_pressed("jump"):
		try_jump()
	
	velocity.y -= gravity * delta

# Attempts a jump - allowed up to jump_limit times per airtime
func try_jump():
	if jumps_used >= jump_limit:
		return
	
	jumps_used += 1
	
	if jumps_used == 1:
		perform_jump()
	elif is_moving():
		perform_flip_jump()
	else:
		perform_jump()

func perform_jump():
	AudioManager.jump_sfx.play()
	AudioManager.jump_sfx.pitch_scale = 1.12
	
	jumpTween()
	play_anim("Jump")
	velocity.y = jump_force

func perform_flip_jump():
	AudioManager.jump_sfx.play()
	AudioManager.jump_sfx.pitch_scale = 0.8
	# "Flip" is used if the character model has that animation (like gobot).
	# Models without it (like the Quaternius Rabbit) fall back to "Jump_Idle".
	var flip_anim = "Flip" if resolve_anim("Flip") != "" else "Jump_Idle"
	play_anim(flip_anim, -1, 2)
	velocity.y = jump_force
	await animation.animation_finished
	play_anim("Jump", 0.5)

func is_moving():
	return abs(velocity.z) > 0 || abs(velocity.x) > 0

func jumpTween():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", jumpStretchSize, 0.1)
	tween.tween_property(self, "scale", Vector3(1,1,1), 0.1)

# Get Player Input
func get_input(_delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_axis("move_left", "move_right")
	move_direction.z = Input.get_axis("move_forward", "move_back")
	
	# Move The player Towards Spring Arm/Camera Rotation
	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	velocity = Vector3(move_direction.x * move_speed, velocity.y, move_direction.z * move_speed)

	move_and_slide()

# Handle Player Animations
func player_animations():
	particle_trail.emitting = false
	footsteps.stream_paused = true
	
	if is_on_floor():
		if is_moving(): # Checks if player is moving
			play_anim("Run", 0.5)
			particle_trail.emitting = true
			footsteps.stream_paused = false
		else:
			play_anim("Idle", 0.5)
