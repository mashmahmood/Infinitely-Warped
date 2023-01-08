extends KinematicBody2D
var enemy = load("res://src/Actors/Enemy_Slime.tscn")
var ENEMYTYPE : int = 0

onready var anim_tree: AnimationTree = $AnimationTree
onready var anim_mode: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
onready var player: Node2D = get_node("../Player")
onready var scene: Node2D = get_parent()
onready var hurt_sound: AudioStreamPlayer = scene.get_node("ImpactSound")

export var GRAVITY = 4000
export var max_generation_index = 4

var velocity: = Vector2.ZERO
var direction: = Vector2(-1, 0)
var direction_timer: float = 0.0
var idle_timer: float = 0.0
var generation_index: int = 0

var hand_inside: bool = false #is the player hand hitting enemy
var death_cooloff: float = 0.0

export var speed : float = 500.0
export var attack_speed : float = 650.0
export var change_direction_time: float = 5.0
export var max_idle_time: float = 2.0


enum States{
	Idle = 0
	Move = 1
	Attacking = 2
}

var current_state: int = States.Move
var animtree : AnimationTree
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	death_cooloff = 0.0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta: float) -> void:
	move(delta)
	die_and_generate(delta)
	
func die_and_generate(delta: float) -> void:
	death_cooloff += delta
	#print(player.shoot_state)
	if hand_inside and player.shoot_state == 1 and death_cooloff > 1.0 and generation_index < max_generation_index: #SHOOTING STATE = 1
		hurt_sound.play()
		anim_mode.travel("Die")
		var new_slime = enemy.instance()
		
		generation_index+=1
		new_slime.generation_index = generation_index
		
		new_slime.position = position + Vector2(75.0, 0.0)
		scene.add_child(new_slime)
		
		death_cooloff = 0.0
	
func move(delta: float) -> void:
	if death_cooloff < 2.0:	#no movement within 2 seconds of dying
		return
		
	velocity.y += delta * GRAVITY
	
	if current_state == States.Attacking:
		anim_mode.travel("Attack")
		var new_velocity: Vector2 = Vector2.RIGHT * global_position.direction_to(player.global_position).dot(Vector2.RIGHT)
		new_velocity.x *= attack_speed
		velocity = Vector2(new_velocity.x, velocity.y)
		
	elif current_state == States.Idle:
		anim_mode.travel("Idle")
		idle_timer += delta
		if idle_timer > max_idle_time:
			
			current_state = States.Move
			idle_timer = 0.0
		velocity.x = 0
	else:
		anim_mode.travel("Walk")
		velocity.x = direction.x * speed
		
		direction_timer += delta
		if direction_timer > change_direction_time:
			direction_timer = 0.0
			direction = -direction
			current_state = States.Idle
	
	velocity = move_and_slide(velocity, Vector2.ZERO)
	
	if velocity.x > 0.15:
		$Sprite.scale.x = -1
	elif velocity.x < -0.15:
		$Sprite.scale.x = 1
		

func _on_PlayerDetector_body_entered(body: Node) -> void:
	current_state = States.Attacking


func _on_PlayerDetector_body_exited(body: Node) -> void:
	current_state = States.Idle


func _on_PlayerHandDetector_body_entered(body: Node) -> void:
	hand_inside = true


func _on_PlayerHandDetector_body_exited(body: Node) -> void:
	hand_inside = false
