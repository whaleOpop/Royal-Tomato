extends inv_base
@onready var item_durability:ProgressBar = $CenterContainer/Panel/item_durability

func update(slot:InvSlot):
	if !slot.item:
		item_display.texture=null
		item_durability.visible=false
	else:
		item_display.texture=slot.item.texture
		if slot.durability>1:
			item_durability.visible=true
		item_durability.value=slot.durability
