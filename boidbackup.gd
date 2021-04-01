extends KinematicBody2D


var velocity = Vector2(0,0)
var speed = 50
var max_velocity = 50

var collision_bias = 10


export var track = false


var alignment_weight = 1


var vel

onready var area = get_node("Area2D")


var collide_bias = Vector2(0,0 )

func _ready():
	randomize()
	velocity.x = rand_range(-max_velocity, max_velocity)
	velocity.y = rand_range(-max_velocity, max_velocity)





func _process(delta):
	
	var neighbors = area.get_overlapping_bodies()
	var alignment = align_with_neighbors(neighbors)
	var cohesion = cohesion(neighbors)
	var collision_avoid = process_obstacle()
	
	
	
	var desired_velocity = alignment + collision_avoid #+ cohesion
	
	velocity = lerp(velocity, velocity + desired_velocity, 0.5)
	
	
	velocity = velocity.normalized() * speed
	rotation = velocity.angle()
	vel = move_and_slide(velocity)



func wrap():
	var size = get_viewport_rect().size
	if 0 > position.y:
		position.y = size.y
	elif position.y > size.y:
		position.y = 0
	
	if 0 > position.x:
		position.x = size.x
	elif position.x > size.x:
		position.x = 0



#func edge_avoid():
#	var viewport_center = get_viewport_rect().size / 2
#	var bias = Vector2(viewport_center.x - self.position.x, viewport_center.y - self.position.y)
#
#	bias.x = clamp(pow(bias.y, 3), -1000, 1000)
#	if track:
#		print(bias.y)
#
#	return bias

func process_obstacle():
	var cum_margin = Vector2(0, 0)
	
	var collision_count = 0
	for i in get_node("sensors").get_children():
		if i.is_colliding() :
			collision_count += 1
			cum_margin += position - i.get_collision_point()
	
	if collision_count > 0:
		var avg_margin = cum_margin/collision_count
		return avg_margin.normalized() * 10
	else:
		return Vector2(0, 0)





func align_with_neighbors(neighbors):
	if neighbors.size() > 0:
		var avg_velocity = Vector2()
		
		var cumu_velo = Vector2()
		for i in neighbors:
			if i.is_in_group("boid") && i != self:
				cumu_velo += i.velocity
		
		avg_velocity = cumu_velo/neighbors.size()
		
		var error_value = avg_velocity - velocity
		
		return error_value
	else:
		print("vector2")
		return Vector2(0,0)


#REWRITE THIS
func cohesion(neighbors):
	var cumu_position = Vector2()
	
	for i in neighbors:
		if self.position.distance_to(i.position) > 1:
			cumu_position -= i.position
		else:
			cumu_position+= i.position
	
	var avg_position = cumu_position/neighbors.size()
	
	var error_value = avg_position - position
	
	return error_value






