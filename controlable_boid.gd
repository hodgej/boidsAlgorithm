extends KinematicBody2D


var speed = 100
var velocity = Vector2()

var velo = Vector2(0,0)

#for testing purposes!
func _process(delta):
	var direction = get_global_mouse_position()
	var angle_to = position.angle_to_point(direction)
	look_at(direction)
	velocity = Vector2(-speed,0).rotated(angle_to)
	velo = move_and_slide(velocity)
