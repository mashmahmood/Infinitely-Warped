extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var game:= get_parent()


var inside_portal = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if inside_portal:
		if Input.is_action_just_pressed("mouse_right_button"):
			game.travel_portal()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Area2D_body_entered(body: Node) -> void:
	inside_portal = true


func _on_Area2D_body_exited(body: Node) -> void:
	inside_portal = false
