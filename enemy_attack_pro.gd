extends Enemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func handle_state(delta):
	match state_current:
		STATES.IDLE:
			state_idle(delta)
		STATES.PATROL:
			state_patrol(delta)
		STATES.ATTACK:
			state_attack(delta)
		STATES.SUPER_ATTACK:
			state_super_attack(delta)

func state_attack(delta):
	if player_character and position.distance_to(player_character.position) < 10:
		state_current = STATES.SUPER_ATTACK
		
	look_at(player_character.global_transform.origin)
	
	var direction = (transform.basis * Vector3(0, 0, -SPEED * delta)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * delta
		velocity.z = direction.z * SPEED * delta

func state_super_attack(delta):
	#print("SUPER attack!")
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
