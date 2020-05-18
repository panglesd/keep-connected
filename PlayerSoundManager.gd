extends Node

signal liberated
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var token = true
var sound_playing
var current_promise
var priority_playing = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func disk_full():
	var sounds = $DiskFull.get_children()
	yield(play(sounds[randi()%sounds.size()],0),"completed")

func good_to_see_you():
	var sounds = $RecoverSignal.get_children()
	yield(play(sounds[randi()%sounds.size()],0),"completed")

func dont_leave_me():
	var sounds = $Restart.get_children()
	yield(play(sounds[randi()%sounds.size()],0),"completed")
	
func discard_memory():
	var sounds = $DiscardMemory.get_children()
	yield(play(sounds[randi()%sounds.size()],0),"completed")

func start_sound():
	var sounds = $Start.get_children()
	yield(play(sounds[randi()%sounds.size()],0),"completed")
	
func on_my_own():
	var sounds = $Playing.get_children()
	yield(play(sounds[randi()%sounds.size()],0),"completed")
	
func end_of_instruction():
	var sounds = $GameOver.get_children()
	yield(play(sounds[randi()%sounds.size()],0),"completed")
	
func recording():
	var sounds = $Recording.get_children()
	yield(play(sounds[randi()%sounds.size()],0),"completed")

#func intro():
#	var sounds = $Intro.get_children()
#	yield(play(sounds[randi()%sounds.size()],1),"completed")
	
func play(sound, priority):
	if not token and priority > priority_playing:
		sound_playing.stop()
		yield(self, "liberated")
	if token:
		sound_playing = sound
		priority_playing = priority
		token = false
		sound.play()
		yield(sound, "finished")
		priority_playing = -1
		sound_playing = null
		token = true
		emit_signal("liberated")
	yield(get_tree().create_timer(0.1), "timeout")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
