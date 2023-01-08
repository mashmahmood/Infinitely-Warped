extends KinematicBody2D
#var enemy = load("res://src/Actors/Enemy_Slime.tscn")
var ENEMYTYPE :int = 1

onready var anim_tree: AnimationTree = $AnimationTree
onready var anim_mode: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
onready var player: Node2D = get_node("../Player")
onready var hurt_sound: AudioStreamPlayer = get_parent().get_node("ImpactSound")

export var GRAVITY = 4000

var velocity: = Vector2.ZERO
var direction: = Vector2(-1, 0)
var direction_timer: float = 0.0
var idle_timer: float = 0.0

var hand_inside: bool = false #is the player hand hitting enemy
var health : float = 100.0

var is_spear_inside : bool = false #or, player_in_range
#var player_in_range: bool = false
var attack_cooloff: float = 2.0
var just_attacked : bool = false
var just_attack_timer : float = 0.0
var death_cooloff: float = 0.0
var hurt_cooloff: float = 0.0
var damage_cooloff: float = 0.0
var generate_cooloff: float = 0.0

export var speed : float = 500.0
export var attack_speed : float = 650.0
export var change_direction_time: float = 5.0
export var max_idle_time: float = 2.0

enum States{
	Idle = 0
	Move = 1
	Attacking = 2
	Hurting = 3
	Dead = 4
}

var current_state: int = States.Move
var animtree : AnimationTree
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	death_cooloff = 0.0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta: float) -> void:
	generate_cooloff += delta
	if generate_cooloff < 1.5:
		return
	move(delta)
	hurt(delta)
	
func hurt(delta: float) -> void:
	damage_cooloff += delta
	
	
	if hand_inside and player.shoot_state == 1 and damage_cooloff > 1.0:
		hurt_sound.play()
		damage_cooloff = 0.0
		current_state = States.Hurting
		health -= 35.0
		if health < 0.0:
			die()
			
func die() -> void:
	#death_cooloff += delta
	#print(player.shoot_state)
	current_state = States.Dead
	anim_mode.travel("Die")
	#var new_slime = enemy.instance()
	
	#generation_index+=1
	#new_slime.generation_index = generation_index
	
	#new_slime.position = position + Vector2(75.0, 0.0)
	#scene.add_child(new_slime)
	
	#death_cooloff = 0.0
	
func move(delta: float) -> void:
	if death_cooloff > 2.0:	#delete after 2 seconds
		queue_free()
		
	velocity.y += delta * GRAVITY
	
	if just_attacked:
		just_attack_timer += delta
		if just_attack_timer > 0.3:
			if is_spear_inside:
				player.hurt(5.0)
				
			just_attacked = false
			just_attack_timer = 0
	
	if current_state == States.Dead:
		velocity.x = 0.0
		death_cooloff += delta
	elif current_state == States.Hurting:
		velocity.x = 0.0
		anim_mode.travel("Hurt")
		hurt_cooloff += delta
		if hurt_cooloff > 2.0:
			hurt_cooloff = 0.0
			current_state = States.Attacking
			
	elif current_state == States.Attacking:
		attack_cooloff += delta
		if is_spear_inside and attack_cooloff > 2.0:
			just_attacked = true
			velocity = Vector2(0, velocity.y)
			anim_mode.travel("Attack")
		else:
			if !nearplayer():
				var new_velocity: Vector2 = Vector2.RIGHT * global_position.direction_to(player.global_position).dot(Vector2.RIGHT)
				new_velocity.x *= attack_speed
				velocity = Vector2(new_velocity.x, velocity.y)
			else:
				velocity = Vector2(0, velocity.y)
		
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
		$Sprite.scale.x = 1
	elif velocity.x < -0.15:
		$Sprite.scale.x = -1
		

func nearplayer() -> bool:
	var val = global_position.distance_to(player.global_position)
	if val < 80.0:
		return true
	return false
###ADD TWO FUNCTIONS THAT DETECT IF PLAYER IN RANGE TO ATTACK


#
#func _on_PlayerHandDetector_body_entered(body: Node) -> void:
#	hand_inside = true
#
#
#func _on_PlayerHandDetector_body_exited(body: Node) -> void:
#	hand_inside = false


func _on_Spear_body_entered(body: Node) -> void:
	is_spear_inside = true



func _on_Spear_body_exited(body: Node) -> void:
	is_spear_inside = false


func _on_PlayerRangeDetector_body_entered(body: Node) -> void:
	current_state = States.Attacking


func _on_PlayerRangeDetector_body_exited(body: Node) -> void:
	current_state = States.Idle


func _on_PlayerHandDetector_body_entered(body: Node) -> void:
	hand_inside = true


func _on_PlayerHandDetector_body_exited(body: Node) -> void:
	hand_inside = false
