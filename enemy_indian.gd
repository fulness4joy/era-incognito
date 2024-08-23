extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var path_length = 10
@onready var start_pos = position

var is_rotate = false
var rotate_value = 0
var rotate_angle = 0 

var hp = 3

enum STATES {IDLE, PATROL, ATTACK}
var state_currwnt = STATES.PATROL

var player_character : CharacterBody3D = null

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction = (transform.basis * Vector3(0, 0, -SPEED * delta)).normalized()
	
	if state_currwnt == STATES.IDLE:
		direction = 0
		
	elif state_currwnt == STATES.PATROL:
		if position.distance_to(start_pos) >= path_length / 2:
			is_rotate = true
			
		if is_rotate == true:
			rotate_value = SPEED * delta
			rotate_y(rotate_value)
			rotate_angle += rotate_value
			
			if rotate_angle >= deg_to_rad(180):
				is_rotate = false
				rotate_angle = 0
			else:
				direction = 0
				
	elif state_currwnt == STATES.ATTACK:
		look_at(player_character.global_transform.origin)
		pass
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func damage(value=1):
	hp -= value
	
	if hp <= 0:
		queue_free()
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "hero":
		print(name + ' помітив ' + body.name)
		player_character = body
		state_currwnt = STATES.ATTACK
