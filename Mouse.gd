extends Area2D

signal hover(body)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
#	Input.set_default_cursor_shape(Input.CURSOR_BUSY)
func _input(event):
	if event is InputEventMouseMotion:
		print(event.relative)
		global_position = get_global_mouse_position() # + event.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position() # + event.position
#	Input.set_default_cursor_shape(Input.CURSOR_BUSY)
	pass


func _on_Mouse_body_entered(body):
	if(body.is_in_group("selectable")):
		if(body.has_method("hovered")):
			body.hovered()
		emit_signal("hover", body)


func _on_Mouse_body_exited(body):
	pass # Replace with function body.


func _on_Mouse_area_entered(area):
	pass # Replace with function body.


func _on_Mouse_area_exited(area):
	pass # Replace with function body.
