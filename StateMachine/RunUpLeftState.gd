extends State

class_name RunUpLeftState

func enter(owners: Node3D):
	owners.scale.x=-1
	pass
	
func exit(owners: Node3D):

	owners.scale.x=1
	pass

func update(owners, delta):
	var velocity = owners.velocity
	velocity.z = owners.SPEED * 0.7071 # 1/sqrt(2) to maintain consistent speed
	velocity.x = -owners.SPEED * 0.7071
	owners.velocity = velocity
	owners.animator.play("RUN_RIGHT")
