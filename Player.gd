extends KinematicBody2D

signal record_time_changed(record)
signal play_time_changed(play)
signal out_of_memory
signal recover_signal
signal activated_checkpoint

export var move_speed = 200
export var gravity = 20
export var less_gravity = 10
export var jump_force = 400

var PlayerSprite = preload("res://PlayerSprite.tscn")

var capacity = 8
var velo = Vector2()
var drag = 0.5

var token_checkpoint = false

var saidByeBye = false

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

var old_db = -10

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

var last_checkpoint = null

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
#	$PlayerSoundManager.intro()
#	$NiceToMeetYou.play()
	pass
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	


func _physics_process(delta):
	if Input.is_action_just_pressed("restart"):
		if not last_checkpoint:
			get_tree().reload_current_scene()
		if last_checkpoint:
			activate_checkpoint()

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
			if not token_checkpoint:
				emit_signal("out_of_memory")
				$PlayerSoundManager.end_of_instruction()
#				$EndOfInstructions.play()
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
			start_recording()
		if Input.is_action_just_released("record"):
			stop_recording()
		if recording:
			set_record_time(min(time_since_recording + delta, capacity))
			if(time_since_recording == capacity):
				$PlayerSoundManager.disk_full()
#				$DiskFull.play()
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
#			print("moveing right", randi())
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
		$PlayerSprite/Sprite.flip_h =true
	elif velo.x>0:
		$PlayerSprite/Sprite.flip_h =false
	if(abs(velo.x)>1):
		print(velo.x)
		$PlayerSprite/AnimationPlayer.play("walk")
	else:
		$PlayerSprite/AnimationPlayer.play("idle")

	velo = move_and_slide(velo, Vector2.UP)
	
	
	
	last_grounded = cur_grounded

################################

func jump():
	if dead:
		return
	$jumpSound.play()
	velo.y = -jump_force

func get_cur_time():
	return OS.get_ticks_msec() / 1000.0

func found_by_emitter():
	count_emitter += 1
	$PlayerSprite/Particles2D.emitting=false
	if playing:
		stop_playing()
	if not connected:
		if not token_checkpoint:
			AudioServer.set_bus_mute(1, false)
#			AudioServer.set_bus_mute(2, false)
			emit_signal("recover_signal")
#			if(saidByeBye and not $OnMyOwn.playing):
			$PlayerSoundManager.good_to_see_you()
#				$GoodToSeeYou.play()
		connected = true
		emit_signal("activated_checkpoint")
		$PlayerSoundManager/Music.volume_db = old_db
func lost_by_emitter():
	count_emitter -= 1
	if(count_emitter == 0):
		AudioServer.set_bus_mute(1, true)
#		AudioServer.set_bus_mute(2, true)
		if not token_checkpoint:
			say_OnMyOwn()
		connected = false
		$PlayerSprite/Particles2D.emitting=true
		old_db = $PlayerSoundManager/Music.volume_db
		$PlayerSoundManager/Music.volume_db = -100
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
	$PlayerSoundManager.recording()
#	$RecordSound.play()
	recording = true
#	start_record_state = state.duplicate()
	pass
	
func stop_recording():
	recording = false
	save_input_in(saved_input, time_since_recording, true)
#	print(len(saved_input))
#	print(saved_input)

func discard_recording():
	$PlayerSoundManager.discard_memory()
#	$ClearingMemory.play()
	stop_recording()
	set_record_time(0)
	set_play_time(0)
	saved_input = []
	
func say_OnMyOwn():
	saidByeBye = false
	yield(get_tree().create_timer(0.2), "timeout")
	if playing:
		$PlayerSoundManager.on_my_own()
#		$OnMyOwn.play()
		saidByeBye = true

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
	
func checkpoint_entered(cp):
	last_checkpoint = cp
	
	
func use_token_activation():
	token_checkpoint = true
	yield(get_tree().create_timer(4.0), "timeout")
	token_checkpoint = false
	
func activate_checkpoint():
	if token_checkpoint:
		return
	use_token_activation()
	emit_signal("activated_checkpoint")
#	$PlayerSoundManager.dont_leave_me()
#	$DontLeaveMe.play()
#	yield($DontLeaveMe,"finished")
	yield($PlayerSoundManager.dont_leave_me(),"completed")
	print(last_checkpoint)
#	$PlayerSprite.duplicate()
	var newPlayerSprite = $PlayerSprite.duplicate()
	newPlayerSprite.get_node("Particles2D").emitting = true
	newPlayerSprite.z_index = -10
	newPlayerSprite.position = $PlayerSprite.global_position
	newPlayerSprite.activated = true
#	if $PlayerSprite.flip_h:
#		newPlayerSprite
	$"../".add_child(newPlayerSprite)
	$Camera2D.smoothing_enabled = true
	var waiting_pos = last_checkpoint.get_node("Sprites").global_position
	
#	$CollisionShape2D.disabled = true
	position = waiting_pos
	$PlayerSoundManager.start_sound()
	var new_pos = yield(last_checkpoint.furnish(), "completed")
	$Camera2D.smoothing_enabled = false
	print(new_pos)
	velo = Vector2(0,0)
	position = new_pos - $PlayerSprite.position
	last_checkpoint.unfurnish()
