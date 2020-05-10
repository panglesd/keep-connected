extends KinematicBody2D


export var move_speed = 200
export var gravity = 20
export var less_gravity = 10
export var jump_force = 400
var velo = Vector2()
var drag = 0.5

const jump_buffer = 0.08
var time_pressed_jump = 0.0
var time_left_ground = 0.0
var last_grounded = false

var facing_right = true

var dead = false
var recording = false
var playing = false
var time_since_recording = 0.0
var time_since_playing = 0.0
var saved_input = []
var count_emitter = 0

var null_input = {
		"is_action_just_pressed(move_left)": false,
		"is_action_just_pressed(move_right)": false,
		"is_action_just_pressed(jump)": false,
		"is_action_just_released(move_left)": false,
		"is_action_just_released(move_right)": false,
		"is_action_just_released(jump)": false,
}

var state = {
	"is_action_pressed(move_right)": false,
	"is_action_pressed(move_left)": false,
	"is_action_pressed(jump)": false
}
var start_record_state = state.duplicate()
var null_state = {
	"is_action_pressed(move_right)": false,
	"is_action_pressed(move_left)": false,
	"is_action_pressed(jump)": false
}

func _draw():
	draw_circle($PositionAntenna.position, 1.0, Color(1,0,0))

func _ready():
	pass
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _physics_process(delta):
	if time_since_recording>0:
		get_parent().get_node("UI/SecondsRecord").text=str(time_since_recording)
	if time_since_playing>0:
		get_parent().get_node("UI/SecondsPlaying").text=str(time_since_playing)
	var input = {
		"is_action_just_pressed(move_left)": Input.is_action_just_pressed("move_left"),
		"is_action_just_pressed(move_right)": Input.is_action_just_pressed("move_right"),
		"is_action_just_pressed(jump)": Input.is_action_just_pressed("jump"),
		"is_action_just_released(move_left)": Input.is_action_just_released("move_left"),
		"is_action_just_released(move_right)": Input.is_action_just_released("move_right"),
		"is_action_just_released(jump)": Input.is_action_just_released("jump"),
	};
	if Input.is_action_just_pressed("delete_record"):
		time_since_recording = 0
		saved_input = []
	if Input.is_action_just_pressed("record"):
		if recording:
			stop_recording()
		else:
			start_recording()
	if recording:
		time_since_recording += delta
		save_input_in(saved_input, time_since_recording)
	if playing:
#		print("play")
		time_since_playing += delta
		if len(saved_input)>0:
			if saved_input[0][1] < time_since_playing:
				handle_input(saved_input.pop_front()[0])
				return
			else:
				handle_input(null_input)

		else:
			handle_input(null_input)

	if not playing:
		handle_input(input)

################################
func save_input_in(saved_input, time_since_recording):
	var input = {
		"dummy": false,
		"is_action_just_pressed(move_left)": Input.is_action_just_pressed("move_left"),
		"is_action_just_pressed(move_right)": Input.is_action_just_pressed("move_right"),
		"is_action_just_pressed(jump)": Input.is_action_just_pressed("jump"),
		"is_action_just_released(move_left)": Input.is_action_just_released("move_left"),
		"is_action_just_released(move_right)": Input.is_action_just_released("move_right"),
		"is_action_just_released(jump)": Input.is_action_just_released("jump"),
	}
	if(not input.values().find(true)):
		return
	saved_input.push_back([input, time_since_recording])
	return

func handle_input(input):
#	print("yo", start_record_state)
	if(input["is_action_just_pressed(move_left)"]):
		state["is_action_pressed(move_left)"] = true
	if(input["is_action_just_pressed(move_right)"]):
		state["is_action_pressed(move_right)"] = true
	if(input["is_action_just_pressed(jump)"]):
		state["is_action_pressed(jump)"] = true
	if(input["is_action_just_released(move_left)"]):
		state["is_action_pressed(move_left)"] = false
	if(input["is_action_just_released(move_right)"]):
		state["is_action_pressed(move_right)"] = false
	if(input["is_action_just_released(jump)"]):
		state["is_action_pressed(jump)"] = false
	
	var move_vec = Vector2()
	if !dead:
		if state["is_action_pressed(move_left)"]:
#			print("moveing left")
			move_vec.x -= 1
		if state["is_action_pressed(move_right)"]:
#			print("moveing right")
			move_vec.x += 1
	
	velo += move_vec * move_speed - drag * Vector2(velo.x, 0)
	
	var cur_grounded = is_on_floor()
	if !cur_grounded and last_grounded:
		time_left_ground = get_cur_time()
	
	var will_jump = false
	var pressed_jump = input["is_action_just_pressed(jump)"]
	
	if pressed_jump:
		time_pressed_jump = get_cur_time()
	
	if (pressed_jump and cur_grounded):
		jump()
	elif (!last_grounded and cur_grounded and get_cur_time() - time_pressed_jump < jump_buffer):
		jump()
	elif pressed_jump and get_cur_time() - time_left_ground < jump_buffer:
		jump()
	
	if state["is_action_pressed(jump)"]:
		velo.y += less_gravity
	else:
		velo.y += gravity
	
	if cur_grounded and velo.y > 10:
		velo.y = 10
	
	velo = move_and_slide(velo, Vector2.UP)
	
	
	
	last_grounded = cur_grounded

################################

func jump():
	if dead:
		return
	velo.y = -jump_force

func get_cur_time():
	return OS.get_ticks_msec() / 1000.0

func found_by_emitter():
	count_emitter += 1
	if playing:
		stop_playing()
	
func lost_by_emitter():
	count_emitter -= 1
	if(count_emitter == 0):
		start_playing()
	
func start_playing():
	playing = true
	state = start_record_state
	time_since_playing = 0

func stop_playing():
	playing = false
	state = compute_state()

func start_recording():
	recording = true
	start_record_state = state.duplicate()
	pass
	
func stop_recording():
	recording = false

func compute_state():
	state = {
		"is_action_pressed(move_right)": Input.is_action_pressed("move_right"),
		"is_action_pressed(move_left)": Input.is_action_pressed("move_left"),
		"is_action_pressed(jump)": Input.is_action_pressed("jump")
	}
	return state
