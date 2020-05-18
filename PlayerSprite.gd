extends KinematicBody2D

export (bool) var activated = false
export (bool) var fromPlayer = true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var gravity = 20

var velo = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not fromPlayer:
		$Particles2D.emitting = true
		if not randi()%9:
			pass
		else:
			$Sprite.visible = false
			if not randi()%8:
				$Sprite2.visible = true
			if not randi()%7:
				$Sprite3.visible = true
			if not randi()%6:
				$Sprite4.visible = true
			if not randi()%5:
				$Sprite5.visible = true
			if not randi()%4:
				$Sprite6.visible = true
			if not randi()%3:
				$Sprite7.visible = true
			if not randi()%2:
				$Sprite8.visible = true
			if not randi()%1:
				$Sprite9.visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	pass
	if activated:
		pass
		velo.y += gravity
		velo = move_and_slide(velo, Vector2.UP)
