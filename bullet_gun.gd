extends RigidBody3D

const speed = 50
const damage_value = 1

var time_disapear = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_central_impulse(transform.basis * Vector3(0, 0, -speed))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#position += transform.basis * Vector3(0, 0, -speed * delta)
	var bodies = get_colliding_bodies()
	
	for body in bodies:
		if body.is_in_group("enemy"):
			body.damage(damage_value)
			queue_free()
			
	time_disapear -= delta
	
	if time_disapear <= 0:
		queue_free()
	
