extends Panel

class_name ItemStackGui

@onready var amountLabel: Label = $Amount
@onready var itemSprite: Sprite2D = $Item

var inventorySlot: InventorySlot

func update():
	if !inventorySlot or !inventorySlot.item:
		return

	itemSprite.visible = true
	itemSprite.texture = inventorySlot.item.texture
	
	# Масштабируем по высоте, чтобы она была 32 пикселя, с сохранением соотношения сторон
	var desired_height = 30.0
	var texture_size = itemSprite.texture.get_size()
	var scale_factor = desired_height / texture_size.y

	itemSprite.set_texture_filter(CanvasItem.TEXTURE_FILTER_NEAREST)
	itemSprite.scale = Vector2(scale_factor, scale_factor)
	
	if inventorySlot.amount > 1:
		amountLabel.visible = true
		amountLabel.text = str(inventorySlot.amount)
	else:
		amountLabel.visible = false
