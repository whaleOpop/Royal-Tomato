extends State

class_name RunDownState

func _init():
	nameSt = "RUN_DOWN"

func enter(owners: Node3D):
	owners.scale.x=1
	pass
func _exit():
	pass
func update(owners: Node3D, delta: float):
	owners.get_child(0).get_child(0).visible=false
	owners.get_child(0).get_child(1).visible=false
	owners.animator.play("RUN_DOWN")
	owners.velocity.x = 0
	owners.velocity.z = -owners.SPEED
