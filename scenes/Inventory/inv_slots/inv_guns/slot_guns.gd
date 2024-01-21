extends Slots
class_name Slots_guns


#Tags Item
#items
#helmet, 
#leggings
#boots
#first_gun
#second_gun
func insert(item:InvItem):
	if(item.tag=="first_gun"):
		slots[0].item=item
	elif(item.tag=="second_gun"):
		slots[1].item=item

		
	update.emit()
	pass
