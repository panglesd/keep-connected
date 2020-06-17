extends Node2D

#onready var player = get_parent().get_node("Player")
onready var raycast = $RayCast2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var seePlayer = false
var listSeenPlayer = []
var spritePerPlayer = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$AnimationPlayer.play("laser")

func _physics_process(delta):
#	update()
#	print("player", player.position, " ", player.global_position)
	var player_list = get_tree().get_nodes_in_group("player")
	var space_state = get_world_2d().direct_space_state
	var i=0
	print("playerlist", player_list)
	for player in player_list:
		print("player", player)
		raycast.collision_mask
		# use global coordinates, not local to node
		var result = space_state.intersect_ray(
			$LaserStart.global_position, 
			player.get_node("PositionAntenna").global_position,
			[],
			raycast.collision_mask)
		raycast.cast_to = player.get_node("PositionAntenna").global_position - $LaserStart.global_position
		if not result:
#		if not raycast.is_colliding():
	#		if raycast.get_collider().is_in_group("player"):
			#$Sprite.set_modulate(Color(0,1,0))
#			if not seePlayer:
#				$Laser.duplicate()
#				$Laser.visible = true
##				player.found_by_emitter()
#				seePlayer = true
			
			if not listSeenPlayer.has(player):
				player.found_by_emitter()
				listSeenPlayer.append(player)
				if not spritePerPlayer.has(player):
					spritePerPlayer[player] = $Laser.duplicate()
					add_child(spritePerPlayer[player])
				spritePerPlayer[player].visible = true
#				$Laser.visible = true
#			spritePerPlayer[player].frame = (spritePerPlayer[player].frame +1 )%3
			if spritePerPlayer[player].region_rect.size.y != (player.get_node("PositionAntenna").global_position - $LaserStart.global_position).length()/2:
				spritePerPlayer[player].region_rect.size.y = (player.get_node("PositionAntenna").global_position - $LaserStart.global_position).length()/2
			if spritePerPlayer[player].rotation != ((player.get_node("PositionAntenna").global_position - $LaserStart.global_position).angle())-PI/2:
				spritePerPlayer[player].rotation = ((player.get_node("PositionAntenna").global_position - $LaserStart.global_position).angle())-PI/2
#			$Laser.region_rect.size.y = (player.get_node("PositionAntenna").global_position - $LaserStart.global_position).length()/2
#			$Laser.rotation = ((player.get_node("PositionAntenna").global_position - $LaserStart.global_position).angle())-PI/2
		else:
			if listSeenPlayer.has(player):
				player.lost_by_emitter()
				spritePerPlayer[player].visible = false
				listSeenPlayer.erase(player)
#			if seePlayer:
#				$Laser.visible = false
#				seePlayer = false
		#$Sprite.set_modulate(Color(1,0,0))
#		print("not colliding")
		
#func _draw():
#	if seePlayer:
#		draw_line(Vector2(), player.get_node("PositionAntenna").global_position - position,Color(1.0,0,0))
#
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
