extends Area2D

signal text_to_write(ttw)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var token = false

export (String) var ttw

# Called when the node enters the scene tree for the first time.
func _ready():
	token = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and not token:
		token = true
		AudioServer.set_bus_mute(2, true)
		$Story.play()
		yield($Story, "finished")
		AudioServer.set_bus_mute(2, false)
		emit_signal("text_to_write", ttw)	
	pass # Replace with function body.

