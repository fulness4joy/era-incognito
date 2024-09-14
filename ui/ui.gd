extends CanvasLayer


@onready var previous_size = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	aim_set()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_size = get_viewport().get_visible_rect().size  
	if current_size != previous_size:
		aim_set()
		previous_size = current_size
		
		
func aim_set():
	var viewport_size = get_viewport().get_visible_rect().size  
	var sprite_size = %AimCross.texture.get_size()  
	%AimCross.position = (viewport_size) / 2	
