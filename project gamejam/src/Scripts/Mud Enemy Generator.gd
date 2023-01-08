extends Sprite

var enemy = load("res://src/Actors/Enemy_Mud.tscn")
onready var scene: Node2D = get_parent().get_parent()
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var player_in_range : bool = false
var new_enemy = null
var generate_cooloff: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	#print(new_enemy)
	if player_in_range and (new_enemy == null or !is_instance_valid(new_enemy)):
		generate_cooloff += delta
		if generate_cooloff > 1.5:
			generate_cooloff = 0.0
			new_enemy = enemy.instance()
			new_enemy.global_position = global_position
			scene.add_child(new_enemy)

func _on_Area2D_body_entered(body: Node) -> void:
	player_in_range = true


func _on_Area2D_body_exited(body: Node) -> void:
	player_in_range = false
