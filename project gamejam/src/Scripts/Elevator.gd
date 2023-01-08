extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var upperTarget: Node2D = get_node("../ElvUpperTarget")
onready var lowerTarget: Node2D = get_node("../ElvLowerTarget")
onready var player: Node2D = get_node("../Player")
onready var teleport: Node2D = get_node("../TELEPORT")
onready var teleport_below: Node2D = get_node("../TELEPORT_BELOW")
export var speed : float = 500
export var needed_standing_time : float = 2.0
export var max_fall_time : float = 2.0
var standing_on : = false
var standing_below := false
var stand_timeoff := 0.0
var falling:= false
var fall_time := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if falling:
		fall_time += delta
		if fall_time > max_fall_time:
			player.global_position = teleport.global_position
			falling = false
			fall_time = 0.0
			
	if standing_below:
		#print("p")
		if player.is_on_floor():
			#print("pp")
			stand_timeoff += delta
		else:
			stand_timeoff = 0.0
			
		if stand_timeoff > needed_standing_time:
			player.global_position.y = teleport_below.global_position.y
			stand_timeoff = 0.0
			falling = true
			standing_on = false
			standing_below = false
	else:
		stand_timeoff = 0.0
		
	
	if standing_on:
		global_position = global_position.move_toward(upperTarget.global_position, delta*speed)
	else:
		global_position = global_position.move_toward(lowerTarget.global_position, delta*speed)

func _on_AboveDetector_body_entered(body: Node) -> void:
	standing_on = true


func _on_AboveDetector_body_exited(body: Node) -> void:
	standing_on = false


func _on_BelowDetector_body_entered(body: Node) -> void:
	standing_below = true

func _on_BelowDetector_body_exited(body: Node) -> void:
	standing_below = false
