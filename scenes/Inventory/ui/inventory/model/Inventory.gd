extends Resource

class_name Inventory

signal updated
signal inventory_supplies_full  # New signal to indicate that the inventory is full
signal inventory_armors_full
signal inventory_guns_full
@export var supplies_slots: Array[InventorySlot]
@export var armors_slots: Array[InventorySlot]
@export var guns_slots: Array[InventorySlot]

func insertSupplies(item: InventoryItem):
	var itemSlots = supplies_slots.filter(func(slot): return slot.item == item)
	if !itemSlots.is_empty():
		if itemSlots[0].amount < item.maxAmountStack:
			itemSlots[0].amount += 1
		else:
			var emptySlots = supplies_slots.filter(func(slot): return slot.item == null)
			if !emptySlots.is_empty():
				emptySlots[0].item = item
				emptySlots[0].amount = 1
			else:
				# Emit signal when no empty slots are available
				print("No space left in inventory.")
				inventory_supplies_full.emit()
				return
	else:
		var emptySlots = supplies_slots.filter(func(slot): return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount = 1
		else:
			# Emit signal when no empty slots are available
			print("No space left in inventory.")
			inventory_supplies_full.emit()
			return
			
	updated.emit()

func insertGuns(item: InventoryItem):
	var itemSlots = guns_slots.filter(func(slot): return slot.item == item)
	if !itemSlots.is_empty():
		if itemSlots[0].amount < item.maxAmountStack:
			itemSlots[0].amount += 1
		else:
			var emptySlots = guns_slots.filter(func(slot): return slot.item == null)
			if !emptySlots.is_empty():
				emptySlots[0].item = item
				emptySlots[0].amount = 1
			else:
				# Emit signal when no empty slots are available
				print("No space left in inventory.")
				inventory_guns_full.emit()
				return
	else:
		var emptySlots = guns_slots.filter(func(slot): return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount = 1
		else:
			# Emit signal when no empty slots are available
			print("No space left in inventory.")
			inventory_guns_full.emit()
			return
			
	updated.emit()

func insertArmors(item: InventoryItem):
	var itemSlots = armors_slots.filter(func(slot): return slot.item == item)
	if !itemSlots.is_empty():
		if itemSlots[0].amount < item.maxAmountStack:
			itemSlots[0].amount += 1
		else:
			var emptySlots = armors_slots.filter(func(slot): return slot.item == null)
			if !emptySlots.is_empty():
				emptySlots[0].item = item
				emptySlots[0].amount = 1
			else:
				# Emit signal when no empty slots are available
				print("No space left in inventory.")
				inventory_armors_full.emit()
				return
	else:
		var emptySlots = armors_slots.filter(func(slot): return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount = 1
		else:
			# Emit signal when no empty slots are available
			print("No space left in inventory.")
			inventory_armors_full.emit()
			return
			
	updated.emit()

func removeSlotSupplies(inventorySlot: InventorySlot):
	var index = supplies_slots.find(inventorySlot)
	if index < 0:
		return
	
	supplies_slots[index] = InventorySlot.new()

func removeSlotGuns(inventorySlot: InventorySlot):
	var index = guns_slots.find(inventorySlot)
	if index < 0:
		return
	
	guns_slots[index] = InventorySlot.new()

func removeSlotArmors(inventorySlot: InventorySlot):
	var index = armors_slots.find(inventorySlot)
	if index < 0:
		return
	
	armors_slots[index] = InventorySlot.new()

func insertSlotSupplies(index: int, inventorySlot: InventorySlot):
	supplies_slots[index] = inventorySlot

func insertSlotGuns(index: int, inventorySlot: InventorySlot):
	guns_slots[index] = inventorySlot

func insertSlotArmors(index: int, inventorySlot: InventorySlot):
	armors_slots[index] = inventorySlot

func isSuppliesFull() -> bool:
	return supplies_slots.filter(func(slot): return slot.item == null).is_empty()

func isGunsFull() -> bool:
	return guns_slots.filter(func(slot): return slot.item == null).is_empty()

func isArmorsFull() -> bool:
	return armors_slots.filter(func(slot): return slot.item == null).is_empty()
