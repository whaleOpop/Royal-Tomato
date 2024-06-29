extends Panel

class_name ItemStackGui

@onready var amountLabel:Label = $Amount
@onready var itemSprite:Sprite2D=$Item

var inventorySlot: InventorySlot

func update():
	if !inventorySlot || !inventorySlot.item: return
	
	itemSprite.visible = true
	itemSprite.texture = inventorySlot.item.texture
	
	if inventorySlot.amount>1:
		amountLabel.visible=true
		amountLabel.text = str(inventorySlot.amount)
	else:
		amountLabel.visible=false

