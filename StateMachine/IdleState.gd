extends State

class_name IdleState

func _init():
	nameSt = "IDLE"



func update(owners: Node3D, delta: float):
	owners.animator.play("IDLE")
	owners.velocity.x = 0
	owners.velocity.z = 0
	pass
