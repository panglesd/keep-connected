extends KinematicBody2D

signal record_time_changed(record)
signal play_time_changed(play)

export var move_speed = 200
export var gravity = 20
export var less_gravity = 10
export var jump_force = 400

var capacity = 8
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
var connected = false
var time_since_recording = 0.0
var time_since_playing = 0.0
var saved_input = []
var count_emitter = 0

var last_input ={
	"dummy": false,
		"is_action_just_pressed(move_left)": false,
		"is_action_just_pressed(move_right)": false,
		"is_action_just_pressed(jump)": false,
		"is_action_just_released(move_left)": false,
		"is_action_just_released(move_right)": false,
		"is_action_just_released(jump)": false,
	"is_action_pressed(move_right)": false,
	"is_action_pressed(move_left)": false,
	"is_action_pressed(jump)": false
}

var null_input = {
	"dummy": false,
		"is_action_just_pressed(move_left)": false,
		"is_action_just_pressed(move_right)": false,
		"is_action_just_pressed(jump)": false,
		"is_action_just_released(move_left)": false,
		"is_action_just_released(move_right)": false,
		"is_action_just_released(jump)": false,
	"is_action_pressed(move_right)": false,
	"is_action_pressed(move_left)": false,
	"is_action_pressed(jump)": false
}

#var state = {
#	"is_action_pressed(move_right)": false,
#	"is_action_pressed(move_left)": false,
#	"is_action_pressed(jump)": false
#}
#var last_state = null
#var null_state = {
#	"is_action_pressed(move_right)": false,
#	"is_action_pressed(move_left)": false,
#	"is_action_pressed(jump)": false
#}

func _draw():
	pass
#	draw_circle($PositionAntenna.position, 1.0, Color(1,0,0))

func _ready():
	$Sprite/AnimationPlayer.play("idle")
	pass
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _physics_process(delta):

	var input = {
		"is_action_pressed(move_left)": Input.is_action_pressed("move_left"),
		"is_action_pressed(move_right)": Input.is_action_pressed("move_right"),
		"is_action_pressed(jump)": Input.is_action_pressed("jump"),
		"is_action_just_pressed(move_left)": Input.is_action_just_pressed("move_left"),
		"is_action_just_pressed(move_right)": Input.is_action_just_pressed("move_right"),
		"is_action_just_pressed(jump)": Input.is_action_just_pressed("jump"),
		"is_action_just_released(move_left)": Input.is_action_just_released("move_left"),
		"is_action_just_released(move_right)": Input.is_action_just_released("move_right"),
		"is_action_just_released(jump)": Input.is_action_just_released("jump"),
	};
	if playing:
#		print("play")
#		time_since_playing += delta
		set_play_time(min(time_since_playing + delta, time_since_recording))
		if time_since_playing == time_since_recording:
			stop_playing()
		if len(saved_input)>0:
			if saved_input[0][1] < time_since_playing:
				last_input = saved_input.pop_front()[0]
			handle_input(last_input)
			return
#			else:
#				handle_input(null_input)

		else:
			print("nothing more to do")
			handle_input(null_input)

	if connected:
		handle_input(input)
		if Input.is_action_just_pressed("delete_record"):
			discard_recording()
		if Input.is_action_just_pressed("record"):
			if recording:
				stop_recording()
			else:
				start_recording()
		if recording:
			set_record_time(min(time_since_recording + delta, capacity))
			if(time_since_recording == capacity):
				stop_recording()
			save_input_in(saved_input, time_since_recording)

	if not connected and not playing:
		handle_input(null_input)

################################
func save_input_in(saved_input, time_since_recording, forced=false):
	var input = {
		"dummy": false,
		"is_action_pressed(move_left)": Input.is_action_pressed("move_left"),
		"is_action_pressed(move_right)": Input.is_action_pressed("move_right"),
		"is_action_pressed(jump)": Input.is_action_pressed("jump"),
		"is_action_just_pressed(move_left)": Input.is_action_just_pressed("move_left"),
		"is_action_just_pressed(move_right)": Input.is_action_just_pressed("move_right"),
		"is_action_just_pressed(jump)": Input.is_action_just_pressed("jump"),
		"is_action_just_released(move_left)": Input.is_action_just_released("move_left"),
		"is_action_just_released(move_right)": Input.is_action_just_released("move_right"),
		"is_action_just_released(jump)": Input.is_action_just_released("jump"),
	}
	if len(saved_input) == 0:
		saved_input.push_back([input, time_since_recording])
		return
	if equal_input(input,saved_input[-1][0]) and not forced:
		return
	saved_input.push_back([input, time_since_recording])
	return

func equal_input(input1, input2):
	for key in input1.keys():
		if input1[key] != input2[key]:
#			print(key, "is false", input1[key], input2[key])
			return false
	return true

func handle_input(input):
	
	var move_vec = Vector2()
	if !dead:
		if input["is_action_pressed(move_left)"]:
#			print("moveing left")
			move_vec.x -= 1
		if input["is_action_pressed(move_right)"]:
			print("moveing right", randi())
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
	
	if input["is_action_pressed(jump)"]:
		velo.y += less_gravity
	else:
		velo.y += gravity
	
	if cur_grounded and velo.y > 10:
		velo.y = 10
	if velo.x<0:
		$Sprite.flip_h =true
	elif velo.x>0:
		$Sprite.flip_h =false

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
		$Sprite/Particles2D.emitting=false
		stop_playing()
	if not connected:
		connected = true
	
func lost_by_emitter():
	count_emitter -= 1
	if(count_emitter == 0):
		connected = false
		$Sprite/Particles2D.emitting=true
		start_playing()
	
func start_playing():
	playing = true
	stop_recording()
#	state = start_record_state
#	time_since_playing = 0

func stop_playing():
	playing = false
#	state = compute_state()

func start_recording():
	recording = true
#	start_record_state = state.duplicate()
	pass
	
func stop_recording():
	recording = false
	save_input_in(saved_input, time_since_recording, true)
#	print(len(saved_input))
#	print(saved_input)

func discard_recording():
	stop_recording()
	set_record_time(0)
	set_play_time(0)
	saved_input = []

#func compute_state():
#	state = {
#		"is_action_pressed(move_right)": Input.is_action_pressed("move_right"),
#		"is_action_pressed(move_left)": Input.is_action_pressed("move_left"),
#		"is_action_pressed(jump)": Input.is_action_pressed("jump")
#	}
#	return state
#

func set_record_time(rt):
	time_since_recording = rt
	emit_signal("record_time_changed", time_since_recording)
#	get_parent().get_node("UI/RecordTime").text=str(time_since_recording)
	
func set_play_time(pt):
	time_since_playing = pt
	emit_signal("play_time_changed", time_since_playing)
#	get_parent().get_node("UI/RecordTime").text=str(time_since_playing)
	
