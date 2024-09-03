extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var boss = get_tree().get_first_node_in_group("boss")
	if boss:
		print("boss")
		boss.character_die.connect(_on_boss_died)

func _on_boss_died():
	#enemy.die()
	print("Boss die!!!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
