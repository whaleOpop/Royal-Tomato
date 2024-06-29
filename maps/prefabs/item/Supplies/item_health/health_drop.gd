extends Area2D

@export var itemRes: InventoryItem

func collect(inventory:Inventory):
	if itemRes.type=="Supplies":
		inventory.insertSupplies(itemRes)
	elif itemRes.type=="Guns":
		inventory.insertGuns(itemRes)
	elif itemRes.type=="Armor":
		inventory.insertArmors(itemRes)
	queue_free()

func showF():
	$Sprite2D2.visible=true
	
func hideF():
	$Sprite2D2.visible=false
