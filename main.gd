extends Node2D


var global_rand_velo 
var max_velocity = 5


func _ready():
	global_rand_velo = rand_range(-max_velocity, max_velocity)

