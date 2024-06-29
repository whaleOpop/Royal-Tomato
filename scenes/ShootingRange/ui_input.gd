extends CanvasLayer

@onready var inventory = $InventoryPlayer

func _ready():
	inventory.close()

func _input(event):
	if event.is_action_pressed("inventory"):
		if inventory.isOpen:
			inventory.close()
			
		else:
			inventory.open()
	
