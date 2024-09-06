extends Node3D


#@export var portal : Node3D = null
@onready var portal = get_tree().get_first_node_in_group("portals")
@onready var hero = get_node("hero")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var boss = get_tree().get_first_node_in_group("boss")
	if boss:
		print("boss")
		boss.character_die.connect(_on_boss_died)
		
	#wwwwwwvar portal = get_node("portal")
	portal.body_entered.connect(_on_portal_entered)
	
	portal.hide()
	print("portal")

func _on_boss_died():
	#enemy.die()
	print("Boss die!!!")
	portal.show()
	
	
func _on_portal_entered(body):
	if body.name == "hero":
		print("pre portal!")
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://home.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
