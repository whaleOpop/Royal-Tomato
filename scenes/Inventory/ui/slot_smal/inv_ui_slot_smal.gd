extends inv_base
@onready var item_amount:Label=$CenterContainer/Panel/item_amount


func update(slot:InvSlot):
	
	if !slot.item:
		item_display.texture=null
		item_amount.visible=false
	else:
		item_display.texture=slot.item.texture
	if slot.amount>1:
		item_amount.visible=true
		item_amount.text=str(slot.amount)

