extends Slots
class_name Slots_items


#Tags Item
#items
#helmet, 
#leggings
#boots
#first_gun
#second_gun
func insert(item:InvItem):
	if(item.tag=="item"):
		var itemslots = slots.filter(func(slot):return slot.item==item)
		if !itemslots.is_empty():
			itemslots[0].amount+=1
		else:
			var emptyslots = slots.filter(func(slot):return slot.item == null)
			if !emptyslots.is_empty():
				emptyslots[0].item=item
				emptyslots[0].amount=1
		update.emit()
	pass
