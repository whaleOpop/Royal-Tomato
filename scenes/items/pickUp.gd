extends Area3D

@export var itemRes: InventoryItem

func collect(inventory: Inventory):
	var can_collect = false  # Initialize a flag to determine if the item can be collected

	if itemRes.type == "Supplies":
		can_collect = not inventory.isSuppliesFull()
	elif itemRes.type == "Guns":
		can_collect = not inventory.isGunsFull()
	elif itemRes.type == "Armor":
		can_collect = not inventory.isArmorsFull()

	if can_collect:
		if itemRes.type == "Supplies":
			inventory.insertSupplies(itemRes)
		elif itemRes.type == "Guns":
			inventory.insertGuns(itemRes)
		elif itemRes.type == "Armor":
			inventory.insertArmors(itemRes)
		queue_free()  # Free the item only if it was successfully collected
	else:
		print("Cannot collect item. Inventory is full.")
