extends inv_base


func update(slot:InvSlot):
	if !slot.item:
		item_display.texture=null
	else:
		item_display.texture=slot.item.texture
