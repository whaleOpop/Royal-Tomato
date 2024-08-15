extends State

class_name RunUpState

func _init():
	nameSt = "RUN_UP"
func enter(owners: Node3D):
	owners.scale.x=1


func update(owners: Node3D, delta: float):
	owners.get_child(0).get_child(0).visible=true
	owners.get_child(0).get_child(1).visible=true

	owners.animator.play("RUN_UP")
	owners.velocity.x = 0
	owners.velocity.z = owners.SPEED
