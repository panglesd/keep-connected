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
	$AnimationPlayer.play("laser")

func _physics_process(delta):
#	update()
#	print("player", player.position, " ", player.global_position)
	raycast.cast_to = player.get_node("PositionAntenna").global_position - $LaserStart.global_position
	if not raycast.is_colliding():
#		if raycast.get_collider().is_in_group("player"):
		#$Sprite.set_modulate(Color(0,1,0))
		Vector2(2,2)
		if not seePlayer:
			$Laser.visible = true
			player.found_by_emitter()
			seePlayer = true
		$Laser.region_rect.size.y = (player.get_node("PositionAntenna").global_position - $LaserStart.global_position).length()/2
		$Laser.rotation = ((player.get_node("PositionAntenna").global_position - $LaserStart.global_position).angle())-PI/2
	else:
		if seePlayer:
			$Laser.visible = false
			player.lost_by_emitter()
			seePlayer = false
		#$Sprite.set_modulate(Color(1,0,0))
#		print("not colliding")
		
#func _draw():
#	if seePlayer:
#		draw_line(Vector2(), player.get_node("PositionAntenna").global_position - position,Color(1.0,0,0))
#
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
