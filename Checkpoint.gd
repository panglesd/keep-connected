extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (String) var checkpoint_number = "Intro"
export (bool) var activated = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if activated:
#		print(get_local_mouse_position())
	pass

func checkpoint_entered(other_cp):
	if self != other_cp:
		$Sprites/ActiveSprites.visible = false
		$Sprites/InactiveSprites.visible = true
	pass

func _on_CheckpointArea_body_entered(body):
	if body.is_in_group("player"):
		$Sprites/ActiveSprites.visible = true
		$Sprites/InactiveSprites.visible = false
		for node in get_tree().get_nodes_in_group("checkpoint_listener"):
			node.checkpoint_entered(self)

func _input(event):
#	print(event.as_text())
	if event.is_action_released("click"):
		var pos = get_global_mouse_position()
		if(pos.distance_to(position)<100):
			print("Click on thingy")
		print("Not Click on thingy")

func furnish():
	$Sprites/PlayerSprite.visible = true
	$Sprites/AnimationPlayer.play("furnish")
	yield($Sprites/AnimationPlayer, "animation_finished")
	print($Sprites/PlayerSprite.global_position)
	return $Sprites/PlayerSprite.global_position

func unfurnish():
	$Sprites/PlayerSprite.visible = false
	$Sprites/AnimationPlayer.play_backwards("furnish")
