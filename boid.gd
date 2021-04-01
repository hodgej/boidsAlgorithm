extends KinematicBody2D


var velocity = Vector2(0,0)
var speed = 50
var max_velocity = 50

var collision_bias = 10


export var track = false


var alignment_weight = 1

var max_seperate = 3

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
	var avg_center = group_center(neighbors)
	var collision_avoid = process_obstacle()
	var goal = (get_node("../player").position-position)/100
	
	#var seperate = seperation(neighbors) //deprecated

	var desired_velocity =  avg_center + collision_avoid*2 + alignment + goal
	
	velocity = lerp(velocity, velocity + desired_velocity, 0.5)
	
	
	velocity = velocity.normalized() * speed
	rotation = velocity.angle()
	vel = move_and_slide(velocity)


func process_obstacle():
	var cum_margin = Vector2(0, 0)
	var multiplier = Vector2(1,1)
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
		return Vector2(0,0)


func group_center(neighbors):
	var cum_center = Vector2()
	var avoid_total = Vector2()
	var total_counted = 0
	
	var net_direction = 0
	
	for i in neighbors:
		if i.is_in_group("boid"):
			if self.position.distance_to(i.position) < 5:
				cum_center += i.position
				total_counted += 1
				net_direction += 1
	var averge_center = cum_center/total_counted
	
	var to_center = averge_center-position
	
	return to_center


func seperation(neighbors):
	var avoid_vector = Vector2()
	var total_counted = 0
	
	var net_direction = 0
	
	for i in neighbors:
		if i.is_in_group("boid") && i != self:
			var diff = position - i.position
			var ratio_dist = diff/self.position.distance_to(i.position)
			
			avoid_vector += ratio_dist
			
			total_counted += 1
	
	var avg_avoidance = avoid_vector/total_counted

	return avg_avoidance
