extends Control

var toShowRestart = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Player_recover_signal():
	$Timer.stop()

func _on_Player_record_time_changed(record):
	$RecordProgress.value = record
	pass # Replace with function body.

func _on_Player_play_time_changed(record):
	$RecordProgress/PlayProgress.value = record
	pass # Replace with function body.


func _on_Timer_timeout():
	$RForRestart.visible = true


func _on_Player_out_of_memory():
	$Timer.start(2)
	pass # Replace with function body.


func _on_Player_activated_checkpoint():
	$RForRestart.visible = false
	pass # Replace with function body.
