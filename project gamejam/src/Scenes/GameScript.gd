extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var player: Node2D = get_node("Player")
onready var R1: Node2D = get_node("R1")
onready var L1: Node2D = get_node("L1")
onready var R2: Node2D = get_node("R2")
onready var L2: Node2D = get_node("L2")
onready var R3: Node2D = get_node("R3")
onready var L3: Node2D = get_node("L3")
var nodes : = []

onready var level1Grad: TextureRect = get_node("CanvasLayer/Gradient")
onready var level2Grad: TextureRect = get_node("CanvasLayer/Gradient2")
onready var level3Grad: TextureRect = get_node("CanvasLayer/Gradient3")

onready var end_screen: TextureRect = get_node("UI/Control/EndScreen")
onready var fail_screen: TextureRect = get_node("UI/Control/FailScreen")
onready var begin_screen: TextureRect = get_node("UI/Control/BeginningScreen")
onready var instruct_screen: TextureRect = get_node("UI/Control/Instructions")
onready var instruct_key: TextureRect = get_node("UI/Control/InstructionsKey")

onready var portal_open: Sprite = get_node("Portal/PortalOpen")

onready var interface_sound: AudioStreamPlayer = get_node("InterfaceSound")
onready var fail_sound: AudioStreamPlayer = get_node("FailSound")



export var level2GradMaxOpacity: float = 0.5
export var level3GradMaxOpacity: float = 0.5
export var change_loop : float = 75.0
export var delta_change : float = 100.0

var collected_keys: int = 0
var gate_unlocked : int = 0
var portal_unlocked : bool = false
var game_over_state: bool = false

enum States{
	First = 0,
	FirstChanging = 1,
	Second = 2,
	SecondChanging = 3,
	Third = 4,
	ThirdChanging = 5
}

var state: int = States.First
var change_timer: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nodes = [R1, L1, R2, L2, R3, L3]
	pass # Replace with function body.

func _process(delta: float) -> void:
	if game_over_state:
		end_screen.visible = true
		show_end_screen(delta)
		return
		
	if player.health <= 0:
		show_fail_screen()
	
	audio()
	change_bg(delta)
	looping(delta)
	pass

func show_end_screen(delta: float) -> void:
	if end_screen.modulate.a < 1.0:
		end_screen.modulate.a += delta
		
func show_fail_screen() -> void:
	fail_sound.play()
	fail_screen.visible = true
		
func travel_portal() -> bool:
	if portal_unlocked:
		game_over()
		return true
	return false
	
func game_over() -> void:
	player.game_finished = true
	game_over_state = true
	
func collect_key() -> void:
	collected_keys += 1
	
func activate_button() -> bool:
	#print(collected_keys)
	if collected_keys > 0:
		gate_unlocked += 1
		collected_keys -= 1
		if gate_unlocked == 3:
			portal_open.visible = true
			portal_unlocked = true
			
		return true
	else:
		instruct_key.visible = true
		return false
	
func audio() -> void:
	if state == States.First:
		$BGMusic3.stop()
		if !$BGMusic1.playing:
			$BGMusic1.play()
	elif state == States.Second:
		$BGMusic1.stop()
		if !$BGMusic2.playing:
			$BGMusic2.play()
			
	elif state == States.Third:
		$BGMusic2.stop()
		if !$BGMusic3.playing:
			$BGMusic3.play()
	
func looping(delta: float) -> void:
	var close_to_node: = false
	
	for node in nodes:
		if node == null:
			continue
		#print("yo")
		if player.global_position.distance_to(node.global_position) < (change_loop*2):
			close_to_node = true
			break
	
	if close_to_node:
		Globals.camera.zoom = Globals.camera.zoom.move_toward(Vector2(0.9, 0.9), delta*0.75)
	else:
		Globals.camera.zoom = Globals.camera.zoom.move_toward(Vector2(1.3, 1.3), delta*0.75)
		
	if player.global_position.distance_to(R1.global_position) < change_loop:
		player.global_position.x = L1.global_position.x + delta_change
	if player.global_position.distance_to(L1.global_position) < change_loop:
		player.global_position.x = R1.global_position.x - delta_change
		
	if player.global_position.distance_to(R2.global_position) < change_loop:
		player.global_position.x = L2.global_position.x + delta_change
	if player.global_position.distance_to(L2.global_position) < change_loop:
		player.global_position.x = R2.global_position.x - delta_change
		
	if player.global_position.distance_to(R3.global_position) < change_loop:
		player.global_position.x = L3.global_position.x + delta_change
	if player.global_position.distance_to(L3.global_position) < change_loop:
		player.global_position.x = R3.global_position.x - delta_change

func change_bg(delta: float) -> void:
	if state == States.FirstChanging:
		if level2Grad.modulate.a < level2GradMaxOpacity:
			level2Grad.modulate.a += delta
		else:
			state = States.Second
	
	if state == States.SecondChanging:
		if level3Grad.modulate.a < level3GradMaxOpacity:
			level3Grad.modulate.a += delta
		if level2Grad.modulate.a > 0:
			level2Grad.modulate.a -= delta
		if level3Grad.modulate.a >= level3GradMaxOpacity and level2Grad.modulate.a <= 0:
			state = States.Third
	
	if state == States.ThirdChanging:
		if level3Grad.modulate.a <= 0:
			state = States.First
		else:
			level3Grad.modulate.a -= delta


func _on_FirstCrossing_body_entered(body: Node) -> void:
	state = States.FirstChanging


func _on_SecondCrossing_body_entered(body: Node) -> void:
	state = States.SecondChanging


func _on_ThirdCrossing_body_entered(body: Node) -> void:
	state = States.ThirdChanging



func _on_Button_TRYAGAIN_button_down() -> void:
	interface_sound.play()
	get_tree().reload_current_scene()


func _on_Button_PLAYAGAIN_button_down() -> void:
	interface_sound.play()
	get_tree().reload_current_scene()


func _on_Button_CONTINUE1_button_down() -> void:
	interface_sound.play()
	begin_screen.visible = false
	instruct_screen.visible = true


func _on_Button_Instruction_button_down() -> void:
	interface_sound.play()
	instruct_screen.visible = false
	player.game_begin = true


func _on_Timer_KeyInstruct_timeout() -> void:
	instruct_key.visible = false
