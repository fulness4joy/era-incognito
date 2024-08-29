extends CharacterBody3D
class_name Enemy


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

enum STATES {IDLE, PATROL, ATTACK, SUPER_ATTACK}
var state_current = STATES.PATROL

var player_character : CharacterBody3D = null
signal character_die

func handle_state(delta):
	match state_current:
		STATES.IDLE:
			state_idle(delta)
		STATES.PATROL:
			state_patrol(delta)
		STATES.ATTACK:
			state_attack(delta)

func state_idle(delta):
	velocity.x = 0
	velocity.y = 0
	
func state_patrol(delta):
	var direction = (transform.basis * Vector3(0, 0, -SPEED * delta)).normalized()
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
			
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
func state_attack(delta):
	
	look_at(player_character.global_transform.origin)
	
	var direction = (transform.basis * Vector3(0, 0, -SPEED * delta)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
func move_character(delta):
	move_and_slide()
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	handle_state(delta)
	move_character(delta)
	
func damage(value=1):
	hp -= value
	
	if hp <= 0:
		character_die.emit(self)
		
	
func die():
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "hero":
		print(name + ' помітив ' + body.name)
		player_character = body
		state_current = STATES.ATTACK
