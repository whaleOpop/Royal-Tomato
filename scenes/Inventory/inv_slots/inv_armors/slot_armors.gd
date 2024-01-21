extends Slots
class_name Slots_armors



#Tags Item
#items
#helmet, 
#leggings
#boots
#first_gun
#second_gun

func insert(item:InvItem):
	
	if(item.tag=="helmet"):
		
		slots[0].item=item
		slots[0].durability=100
	elif(item.tag=="leggings"):
		slots[1].item=item
		slots[1].durability=100
	elif(item.tag=="boots"):
		slots[2].item=item
		slots[2].durability=100
	update.emit()
	pass
	
func drop():
	pass
