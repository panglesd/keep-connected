extends Node2D

onready var player = get_parent().get_node("Player")
onready var raycast = $RayCast2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var seePlayer = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	update()
#	print("player", player.position, " ", player.global_position)
	raycast.cast_to = player.get_node("PositionAntenna").global_position - position
	if not raycast.is_colliding():
#		if raycast.get_collider().is_in_group("player"):
		$Sprite.set_modulate(Color(0,1,0))
		if not seePlayer:
			player.found_by_emitter()
			seePlayer = true
	else:
		if seePlayer:
			player.lost_by_emitter()
			seePlayer = false
		$Sprite.set_modulate(Color(1,0,0))
#		print("not colliding")
		
func _draw():
	if seePlayer:
		draw_line(Vector2(), player.get_node("PositionAntenna").global_position - position,Color(1.0,0,0))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
