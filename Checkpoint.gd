extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (String) var checkpoint_number = "Intro"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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

func furnish():
	$Sprites/PlayerSprite.visible = true
	$Sprites/AnimationPlayer.play("furnish")
	yield($Sprites/AnimationPlayer, "animation_finished")
	print($Sprites/PlayerSprite.global_position)
	return $Sprites/PlayerSprite.global_position

func unfurnish():
	$Sprites/PlayerSprite.visible = false
	$Sprites/AnimationPlayer.play_backwards("furnish")
