extends Control


signal opened
signal closed
var isOpen: bool = false

@onready var inventory: Inventory = preload("res://scenes/Inventory/Inventory.tres")
@onready var small_slots:Array = $NinePatchRect/HBoxContainer/LargestContainer/SmallContainer.get_children()
@onready var middle_slots:Array = $NinePatchRect/HBoxContainer/MiddleContainer.get_children()
@onready var large_slots:Array = $NinePatchRect/HBoxContainer/LargeContainer.get_children()

@onready var ItemStackGuiClass = preload("res://scenes/Inventory/ui/inventory/slots/small/itemStackGui.tscn")
@onready var ItemStackGuiClassmiddle = preload("res://scenes/Inventory/ui/inventory/slots/small/itemStackGui.tscn")
@onready var ItemStackGuiClasslarge = preload("res://scenes/Inventory/ui/inventory/slots/small/itemStackGui.tscn")

var itemInHand:ItemStackGui
var oldIndex: int = -1
var locked:bool=false

func _ready():
	connectSlotsSmall()
	connectSlotsMiddle()
	connectSlotsLarge()
	inventory.updated.connect(updateSupplies)
	inventory.updated.connect(updateGuns)
	inventory.updated.connect(updateArmors)
	updateSupplies()
	updateGuns()
	updateArmors()
	
func connectSlotsSmall():
	for i in range(small_slots.size()):
		var slot = small_slots[i]
		slot.index=i
		var callable= Callable(onSlotClicked)
		callable= callable.bind(slot)
		slot.pressed.connect(callable)
func connectSlotsMiddle():	
	for i in range(middle_slots.size()):
		var slot = middle_slots[i]
		slot.index=i
		var callable= Callable(onSlotClicked)
		callable= callable.bind(slot)
		slot.pressed.connect(callable)
func connectSlotsLarge():	
	for i in range(large_slots.size()):
		var slot = large_slots[i]
		slot.index=i
		var callable= Callable(onSlotClicked)
		callable= callable.bind(slot)
		slot.pressed.connect(callable)
		
	
		
func updateSupplies():
	for i in range(min(inventory.supplies_slots.size(),small_slots.size())):
		var inventorySlot: InventorySlot = inventory.supplies_slots[i]
		
		if !inventorySlot.item:continue
		
		var itemStackGui: ItemStackGui =small_slots[i].itemStackGui
		
		if !itemStackGui:
			itemStackGui=ItemStackGuiClass.instantiate()
			small_slots[i].insertSupplies(itemStackGui)
		itemStackGui.inventorySlot=inventorySlot
		itemStackGui.update()
func updateArmors():
	for i in range(min(inventory.armors_slots.size(),middle_slots.size())):
		var inventorySlot: InventorySlot = inventory.armors_slots[i]
		
		if !inventorySlot.item:continue
		
		var itemStackGui: ItemStackGui = middle_slots[i].itemStackGui
		
		if !itemStackGui:
			itemStackGui=ItemStackGuiClassmiddle.instantiate()
			middle_slots[i].insertArmors(itemStackGui)
		itemStackGui.inventorySlot=inventorySlot
		itemStackGui.update()
func updateGuns():
	for i in range(min(inventory.guns_slots.size(),large_slots.size())):
		var inventorySlot: InventorySlot = inventory.guns_slots[i]
		
		if !inventorySlot.item:continue
		
		var itemStackGui: ItemStackGui = large_slots[i].itemStackGui
		
		if !itemStackGui:
			itemStackGui=ItemStackGuiClasslarge.instantiate()
			large_slots[i].insertGuns(itemStackGui)
		itemStackGui.inventorySlot=inventorySlot
		itemStackGui.update()
	pass

func open():
	visible=true
	isOpen=true
	opened.emit()
	
func close():
	visible=false
	isOpen=false
	closed.emit()
	
func onSlotClicked(slot):
	
	if locked:return
	
	
	if slot.isEmpty():
		if  !itemInHand: return	
		if slot.getType()=="Supplies":
			if itemInHand.inventorySlot.item.type=="Supplies":
				insertItemInSlotSupplies(slot)
				return
		elif slot.getType()=="Guns":
			if itemInHand.inventorySlot.item.type=="Guns":
				insertItemInSlotGuns(slot)
				return
		elif slot.getType()=="Armor":
			if itemInHand.inventorySlot.item.type=="Armor":
				insertItemInSlotArmors(slot)
				return
		
		
	
	if !itemInHand:
		
		if slot.itemStackGui.inventorySlot.item.type=="Supplies":
			takeItemFromSlotSupplies(slot)
		elif slot.itemStackGui.inventorySlot.item.type=="Guns":
			takeItemFromSlotGuns(slot)
		elif slot.itemStackGui.inventorySlot.item.type=="Armor":
			takeItemFromSlotSupplies(slot)
		return
	if slot.getType()==itemInHand.inventorySlot.item.type:
		if slot.itemStackGui.inventorySlot.item.name==itemInHand.inventorySlot.item.name:
			stackItemsSupplies(slot)
			return
	if slot.getType()=="Supplies":
		if itemInHand.inventorySlot.item.type=="Supplies":
			swapItemsSupplies(slot)
	elif slot.getType()=="Guns":
		if itemInHand.inventorySlot.item.type=="Guns":
			swapItemsGuns(slot)
	elif slot.getType()=="Armor":
		if itemInHand.inventorySlot.item.type=="Armor":
			swapItemsArmors(slot)
	
	
func takeItemFromSlotSupplies(slot):
	itemInHand = slot.takeItemSupplies()
	add_child(itemInHand)
	updateItemInHand()
	oldIndex = slot.index

func takeItemFromSlotGuns(slot):
	itemInHand = slot.takeItemGuns()
	add_child(itemInHand)
	updateItemInHand()
	oldIndex = slot.index

func takeItemFromSlotArmors(slot):
	itemInHand = slot.takeItemArmors()
	add_child(itemInHand)
	updateItemInHand()
	oldIndex = slot.index




func stackItemsSupplies(slot):
	var slotItem:ItemStackGui = slot.itemStackGui
	var maxAmount=slotItem.inventorySlot.item.maxAmountStack
	var totalAmount = slotItem.inventorySlot.amount+itemInHand.inventorySlot.amount
	
	if slotItem.inventorySlot.amount==maxAmount:
		swapItemsSupplies(slot)
		return
		
	if totalAmount<=maxAmount:
		slotItem.inventorySlot.amount=totalAmount
		remove_child(itemInHand)
		itemInHand=null
		oldIndex=-1
	else:
		slotItem.inventorySlot.amount = maxAmount
		itemInHand.inventorySlot.amount=totalAmount-maxAmount
	slotItem.update()
	if itemInHand:itemInHand.update()
	

func swapItemsSupplies(slot):
	var tempItem = slot.takeItemSupplies()
	
	insertItemInSlotSupplies(slot)
	
	itemInHand=tempItem
	add_child(itemInHand)
	updateItemInHand()

func swapItemsGuns(slot):
	var tempItem = slot.takeItemGuns()
	
	insertItemInSlotGuns(slot)
	
	itemInHand=tempItem
	add_child(itemInHand)
	updateItemInHand()

func swapItemsArmors(slot):
	var tempItem = slot.takeItemArmors()
	
	insertItemInSlotArmors(slot)
	
	itemInHand=tempItem
	add_child(itemInHand)
	updateItemInHand()

func insertItemInSlotSupplies(slot):
	var item = itemInHand
	remove_child(itemInHand)
	itemInHand=null
	slot.insertSupplies(item)
	
	oldIndex = -1
	pass

func insertItemInSlotGuns(slot):
	if slot.getType()=="Guns":
		var item = itemInHand
		remove_child(itemInHand)
		itemInHand=null
		slot.insertGuns(item)
		
		oldIndex = -1
		pass

func insertItemInSlotArmors(slot):
	var item = itemInHand
	remove_child(itemInHand)
	itemInHand=null
	slot.insertArmors(item)
	
	oldIndex = -1
	pass
	
func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position=get_global_mouse_position()-itemInHand.size/2

func _input(_event):

	updateItemInHand()
	
