extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const SPEED_ROTATE = 0.01

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var anim_player = $hero/AnimationPlayer
@onready var bullet_gun = load("res://bullet_gun.tscn")

var current_weapen = "gun"

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	#else:
		#anim_player.play("walk")
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim_player.play("jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#if Input.is_action_pressed("rotate_left"):
		#rotate_y(SPEED_ROTATE * delta)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _input(event):
	# Change game mode
	if Input.is_action_just_released("enter_game"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_released("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
	# Change View
	if Input.is_action_just_released("change_view"):
		if %third_p_camera.current:
			%first_p_camera.current = true
		else: 
			%third_p_camera.current = true
			
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SPEED_ROTATE)
		if %first_p_camera.current == true:
			%first_p_camera.rotate_x(-event.relative.y * SPEED_ROTATE)
			%first_p_camera.rotation.x = clamp(%first_p_camera.rotation.x, -deg_to_rad(55), deg_to_rad(55))
	# SHOOT		
	if Input.is_action_just_pressed("shoot"):
		if current_weapen == "gun":
			anim_player.play("idle_gun")
			var inst = bullet_gun.instantiate()
			inst.position = %ray_bullet_gun.global_position
			inst.transform.basis =  %ray_bullet_gun.global_transform.basis
			
			get_tree().get_root().add_child(inst)
			
		if current_weapen == "rifle":
			if %ray_bullet_rifle.is_colliding():
				var body = %ray_bullet_rifle.get_collider()
				if body.is_in_group("enemy"):
					body.damage(3)
					
	if Input.is_action_just_pressed("change_weapon"):
		if current_weapen == "gun":
			current_weapen = "rifle"
		else:
			current_weapen = "gun"
	#print(current_weapen)
