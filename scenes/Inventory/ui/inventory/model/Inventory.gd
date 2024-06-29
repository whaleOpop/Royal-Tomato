extends Resource

class_name Inventory

signal updated

@export var supplies_slots: Array[InventorySlot]
@export var armors_slots: Array[InventorySlot]
@export var guns_slots: Array[InventorySlot]


func insertSupplies(item: InventoryItem):
	var itemSlots = supplies_slots.filter(func(slot):return slot.item == item)
	if !itemSlots.is_empty():
		if itemSlots[0].amount<item.maxAmountStack:
			itemSlots[0].amount+=1
		else:
			var emptySlots = supplies_slots.filter(func(slot): return slot.item == null)
			if!emptySlots.is_empty():
				emptySlots[0].item = item
				emptySlots[0].amount = 1
			else:
				# Handle the case where no empty slots are available
				print("No space left in inventory.")
	else:
		var emptySlots=supplies_slots.filter(func(slot):return slot.item==null)
		if !emptySlots.is_empty():
			emptySlots[0].item=item
			emptySlots[0].amount=1
			
	updated.emit()

func insertGuns(item: InventoryItem):
	var itemSlots = guns_slots.filter(func(slot):return slot.item == item)
	if !itemSlots.is_empty():
		if itemSlots[0].amount<item.maxAmountStack:
			itemSlots[0].amount+=1
		else:
			var emptySlots = guns_slots.filter(func(slot): return slot.item == null)
			if!emptySlots.is_empty():
				emptySlots[0].item = item
				emptySlots[0].amount = 1
			else:
				# Handle the case where no empty slots are available
				print("No space left in inventory.")
	else:
		var emptySlots=guns_slots.filter(func(slot):return slot.item==null)
		if !emptySlots.is_empty():
			emptySlots[0].item=item
			emptySlots[0].amount=1
			
	updated.emit()
	
func insertArmors(item: InventoryItem):
	var itemSlots = armors_slots.filter(func(slot):return slot.item == item)
	if !itemSlots.is_empty():
		if itemSlots[0].amount<item.maxAmountStack:
			itemSlots[0].amount+=1
		else:
			var emptySlots = armors_slots.filter(func(slot): return slot.item == null)
			if!emptySlots.is_empty():
				emptySlots[0].item = item
				emptySlots[0].amount = 1
			else:
				# Handle the case where no empty slots are available
				print("No space left in inventory.")
	else:
		var emptySlots=armors_slots.filter(func(slot):return slot.item==null)
		if !emptySlots.is_empty():
			emptySlots[0].item=item
			emptySlots[0].amount=1
			
	updated.emit()
	
func removeSlotSupplies(inventorySlot:InventorySlot):
	var index = supplies_slots.find(inventorySlot)
	if index<0:return
	
	supplies_slots[index] = InventorySlot.new()
		
func removeSlotGuns(inventorySlot:InventorySlot):
	var index = guns_slots.find(inventorySlot)
	if index<0:return
	
	guns_slots[index] = InventorySlot.new()
	
func removeSlotArmors(inventorySlot:InventorySlot):
	var index = armors_slots.find(inventorySlot)
	if index<0:return
	
	armors_slots[index] = InventorySlot.new()
	
func insertSlotSupplies(index:int,inventorySlot:InventorySlot):
	supplies_slots[index]=inventorySlot

func insertSlotGuns(index:int,inventorySlot:InventorySlot):
	
	guns_slots[index]=inventorySlot

func insertSlotArmors(index:int,inventorySlot:InventorySlot):
	armors_slots[index]=inventorySlot
		
	
