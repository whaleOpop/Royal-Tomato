extends Node

class_name InventoryState
func enter(owner):
	# Stop the character's horizontal movement when entering the inventory state
	owner.velocity.x = 0
	owner.velocity.z = 0

func exit(owner):
	# Called when exiting the inventory state
	pass

func update(owner, delta):
	# Allow gravity to be applied
	if not owner.is_on_floor():
		owner.velocity.y -= owner.gravity * delta

	# Keep the character in place (no horizontal movement)
	owner.animator.play("IDLE")
	owner.move_and_slide()
