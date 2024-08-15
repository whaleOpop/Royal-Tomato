extends State

class_name RunRightState

func _init():
	nameSt = "RUN_RIGHT"
func enter(owners: Node3D):
	owners.scale.x=1
func exit(owners: Node3D):

	pass

func update(owners: Node3D, delta: float):
	owners.get_child(0).get_child(0).visible=true
	owners.get_child(0).get_child(1).visible=true
	owners.animator.play("RUN_RIGHT")
	owners.velocity.x = owners.SPEED
	owners.velocity.z = 0
