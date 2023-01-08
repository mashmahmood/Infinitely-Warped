extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
enum HandState{
	Aiming,
	GoingForward,
	ComingBack,
	Idle
}
var current_hand_state: int = HandState.Idle
var current_target: Vector2
export var forward_max_time : float = 2
export var hand_speed : float = 100

var forward_timer : float = 0.0
var original_position: Vector2 #RELATIVE POSITON
var time_of_shoot_position: Vector2
var original_rotation: float
var default_target: Node2D

var given_power: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = position
	original_rotation = rotation_degrees
	default_target = get_parent().get_node("default_target")
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	update_position(delta)
	
	
func update_position(delta: float) -> void:
	var direction: Vector2 = time_of_shoot_position.direction_to(current_target)
	if current_hand_state == HandState.ComingBack:
		direction = global_position.direction_to(time_of_shoot_position)
	
	var new_velocity : Vector2 = direction * hand_speed * (given_power+0.1)
	
	var speed_modulator : float
	
	if current_hand_state == HandState.Aiming:
		look_at(current_target)
	
	elif current_hand_state == HandState.GoingForward:
		forward_timer += delta
		speed_modulator = (forward_max_time-forward_timer) + 0.1
		move_and_collide(new_velocity * speed_modulator)
		if forward_timer > forward_max_time * given_power:
			forward_timer = 0.0
			current_hand_state = HandState.ComingBack

	elif current_hand_state == HandState.ComingBack:
		
#		forward_timer += delta
#		speed_modulator = forward_timer + 0.1
#		move_and_collide(-new_velocity * speed_modulator)
#		if forward_timer > forward_max_time:
#			forward_timer = 0.0
#			current_hand_state = HandState.Idle
#			#RESET POSITION AND ROTATION
#			reset_hand()
		move_and_collide(new_velocity * 0.3)
		#print(time_of_shoot_position.distance_squared_to(global_position))
		if time_of_shoot_position.distance_squared_to(global_position) < 300:
			forward_timer = 0.0
			current_hand_state = HandState.Idle
			reset_hand()
			

func reset_hand() -> void:
	current_hand_state = HandState.Idle
	position = original_position
	rotation_degrees = original_rotation
	current_target = default_target.global_position
	
func get_state() -> int:
	if current_hand_state == HandState.Idle:
		return 0
	else:
		return 1
	
func update_state(target: Vector2, player_direction: int, state: int, power: float) -> void:
	#print(player_direction)
	given_power = power
	
	if player_direction == -1.0:
		if target.x - global_position.x < 0:
			current_target = target
	else:
		if global_position.x - target.x < 0:
			current_target = target
	
	#print(state)
	if state == 0:
		current_hand_state = HandState.Aiming
	elif state == 1:
		time_of_shoot_position = global_position
		current_hand_state = HandState.GoingForward
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
