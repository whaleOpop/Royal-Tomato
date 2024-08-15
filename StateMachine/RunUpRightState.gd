extends State

class_name RunUpRightState



func update(owners, delta):
	var velocity = owners.velocity
	velocity.z = owners.SPEED * 0.7071
	velocity.x = owners.SPEED * 0.7071
	owners.velocity = velocity
	owners.animator.play("RUN_RIGHT")
	
func exit(owners):
	pass
