extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var health_bar: ProgressBar = get_parent().get_node("UI/Control/HealthBar")
onready var hand_sound: AudioStreamPlayer = get_node("Hand_Sound")

var velocity: Vector2
export var speed: = Vector2(300.0, 1000.0)
export var gravity: = 4000
export var float_max := 2.0
export var health := 100.0
export var slime_damage_rate : float = 0.5
export var camera_damage_cooloff : float = 2.0
export var max_aim_time: float = 1.2

var camera_shake_timer : float = 0.0
var aim_time: float = 0.0


var original_position: Vector2
var facing_direction: int = 1

var float_value : = 0.0
var float_state : = false

enum ShootState{
	aiming = 0,
	shooting = 1,
	idle = 2
}

var interacting_slimes: int = 0
var damage_trigger_timer: float = 0

var shoot_state :int = ShootState.idle
var left_hand : Node2D

var game_begin: bool = false
var game_finished: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = $Sprite.position
	left_hand = get_node("Sprite/LeftHandKI")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta: float) -> void:
	if !game_begin:
		return
	if game_finished:
		return
	var direction: Vector2 = get_direction()
	velocity = calculate_move_velocity(velocity, direction, speed)
	velocity = move_and_slide(velocity, Vector2.UP)
	animate_body(velocity)
	process_shooting(delta)
	health_system(delta)
	audio_effect()
	
func audio_effect() -> void:
	if !hand_sound.playing and shoot_state == ShootState.shooting:
		hand_sound.play()
		
func process_shooting(delta: float) -> void:
	if velocity.normalized() != Vector2.ZERO:
		return
	#NOT SHOOTABLE POSITION

			
	if shoot_state == ShootState.idle:
		if Input.is_action_just_pressed("mouse_left_button"):
			left_hand.reset_hand()
			left_hand.update_state(get_global_mouse_position(), facing_direction, 0, 0.0)
			shoot_state = ShootState.aiming
			
	if shoot_state == ShootState.aiming:
		aim_time += delta
		var power: float = aim_time / max_aim_time
		if power > 1.0:
			power = 1.0
			
		var front_dir: = Vector2(facing_direction, 0)
		var aim_dir: float = front_dir.dot(get_global_mouse_position()-global_position)
		
		if aim_dir < 0:
			toggle_orientation()
		
		left_hand.update_state(get_global_mouse_position(), facing_direction, 0, power)
		if Input.is_action_just_released("mouse_left_button"):
#			if $Sprite/LeftHandKI/RayCast2D.is_colliding():
#				shoot_state = ShootState.idle
#				left_hand.reset_hand()
#			else:
			left_hand.update_state(get_global_mouse_position(), facing_direction, 1, power)
			shoot_state = ShootState.shooting
			
	if shoot_state == ShootState.shooting:
		if left_hand.get_state() == 0:
			aim_time = 0.0
			shoot_state = ShootState.idle
	

func get_direction() -> Vector2:
	if shoot_state == ShootState.shooting or shoot_state == ShootState.aiming:
		return Vector2.ZERO
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-Input.get_action_strength("jump") if is_on_floor() and Input.is_action_just_pressed("jump") else 0.0
	)

func toggle_orientation() -> void:
	$Sprite.scale.x *= -1
	if facing_direction == 1:
		facing_direction = -1
	else:
		facing_direction = 1
		
func change_orientation(direction: float) -> void:
	if direction < 0:
		$Sprite.scale.x = -1
		facing_direction = -1
	elif direction > 0:
		$Sprite.scale.x = 1
		facing_direction = 1
		
func calculate_move_velocity(
	linear_velocity: Vector2,
	direction: Vector2,
	speed: Vector2
) -> Vector2:
	var new_velocity = linear_velocity
	new_velocity.x = speed.x * direction.x
	
	change_orientation(direction.x)
	
	new_velocity.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		new_velocity.y = speed.y * direction.y
	return new_velocity
	
func animate_body(velocity: Vector2) -> void:
	if velocity.length_squared() != 0:
		return
		
	var max_position : = Vector2(0.0, float_max)
	$Sprite.position = lerp(
		original_position + max_position, original_position - max_position, float_value
		)
		
	if !float_state:
		float_value += get_physics_process_delta_time()
		if float_value > 1.0:
			float_state = true
	else:
		float_value -= get_physics_process_delta_time()
		if float_value < 0.0:
			float_state = false
	

func die() -> void:
	game_finished = true
	pass
	#queue_free()
	
func camshake() -> void:
	if camera_shake_timer > camera_damage_cooloff:
		camera_shake_timer = 0.0
		Globals.camera.shake(500, 0.3, 500)
	
func hurt(damage: float) -> void:
	camshake()
	health -= damage

func health_system(delta: float) -> void:
	
	camera_shake_timer += delta
	if interacting_slimes > 0:
		hurt(interacting_slimes * slime_damage_rate * delta)
	
	health_bar.value = health
	#print(health)
	if health <= 0:
		die()

func _on_EnemyDetector_body_entered(body: Node) -> void:
	if body.ENEMYTYPE == 0:
		interacting_slimes+=1
	

func _on_EnemyDetector_body_exited(body: Node) -> void:
	if body.ENEMYTYPE == 0:
		interacting_slimes-=1
