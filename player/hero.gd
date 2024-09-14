extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const SPEED_ROTATE = 0.01

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var anim_player = $hero/AnimationPlayer
@onready var anim_player_effects = $AnimationPlayer
@onready var bullet_gun = load("res://bullet_gun.tscn")

# Aim
@onready var aim_cross = $"../UI/AimCross"

# Попередня анімація
var old_anim = null

# Зброя, яка э в гравця
static var WEAPONS = []
# Активна, обрана зброя
var current_weapen = null

#var hp = 10

# Пістолет
const time_gun_recharge = 0.5
var timer_gun_shot = time_gun_recharge

# Рушниця
const time_rifle_recharge = 1
var timer_rifle_shot = time_rifle_recharge

@onready var sparks_scene = load("res://sparks.tscn")


func _ready() -> void:
	if aim_cross:
		aim_cross.hide()
		
	weapon_check()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#if Input.is_action_pressed("rotate_left"):
		#rotate_y(SPEED_ROTATE * delta)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if is_on_floor():
			animate_process("walk")
			anim_player_effects.play("walking")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if is_on_floor():
			animate_process("idle")
			
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animate_process("jump")

	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i).get_collider()
		if col.name == "gun":
			WEAPONS.append("gun")
			weapon_check()
			col.visible = false
			
	move_and_slide()

	timer_gun_shot += delta
	timer_rifle_shot += delta
	print(Globals.HP)


func change_view(mode = null):
	if %third_p_camera.current:
		%first_p_camera.current = true
		aim_cross.show()
	else: 
		%third_p_camera.current = true
		aim_cross.hide()
	
	
func _input(event):
	Globals.HP -= 1
	# Change game mode
	if Input.is_action_just_released("enter_game"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_released("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
	# Change View
	if Input.is_action_just_released("change_view"):
		change_view()
			
	if Input.is_action_just_pressed("front_view"):
		%CameraFront.current = true
			
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SPEED_ROTATE)
		if %first_p_camera.current == true:
			%first_p_camera.rotate_x(-event.relative.y * SPEED_ROTATE)
			%first_p_camera.rotation.x = clamp(%first_p_camera.rotation.x, -deg_to_rad(55), deg_to_rad(55))
	# SHOOT		
	if Input.is_action_just_pressed("shoot"):
		if current_weapen == "gun" and timer_gun_shot >= time_gun_recharge:
			var inst = bullet_gun.instantiate()
			inst.position = %ray_bullet_gun.global_position
			inst.transform.basis =  %ray_bullet_gun.global_transform.basis
			
			get_tree().get_root().add_child(inst)
			timer_gun_shot = 0
			
		if current_weapen == "rifle" and timer_rifle_shot >= time_rifle_recharge:
			anim_player_effects.play("hut_jump")
			if %ray_bullet_rifle.is_colliding():
				var body = %ray_bullet_rifle.get_collider()
				var sparks = sparks_scene.instantiate()
				sparks.position = %ray_bullet_rifle.get_collision_point()
				get_tree().get_root().add_child(sparks)
				
				sparks.connect("finished", sparks.queue_free)
				
				if body.is_in_group("enemy"):
					body.damage(3)
					
				timer_rifle_shot = 0
				
	# Change weapon				
	if Input.is_action_just_pressed("change_weapon"):
		set_next_weapon()
			
		
func animate_process(state_anim):
	# Аниімація не змінилась - вихід з функції
		
	if current_weapen:
		state_anim += '_' + current_weapen
		
	anim_player.play(state_anim)
	#print(state_anim)
	old_anim = state_anim


func weapon_check():
	for weapon in WEAPONS:
		find_child(weapon).visible = true

func set_next_weapon():
	# Вибираємо наступну зброю в списку
	var new_index = WEAPONS.find(current_weapen) + 1 if current_weapen else 0
	# Якщо список закінчився, починаємо спочатку
	if new_index == len(WEAPONS): 
		current_weapen = null
	else:
		current_weapen = WEAPONS[new_index]
	#print(current_weapen)
