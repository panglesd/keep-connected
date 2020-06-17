extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var followed_node_2d
export var margin_v = 0.9
export var margin_h = 0.9

signal camera_hooked(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func follow_node(node):
	followed_node_2d = node
	emit_signal("camera_hooked", node)

func leave_node(node):
	followed_node_2d = null
	emit_signal("camera_unhooked")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("click"):
		follow_node($Mouse)
	if followed_node_2d:
		$Camera2D.global_position = followed_node_2d.global_position
