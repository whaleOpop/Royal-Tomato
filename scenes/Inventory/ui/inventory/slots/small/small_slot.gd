extends Button

@onready var backgroundSprite:Sprite2D = $Background
@onready var container:CenterContainer = $CenterContainer

@onready var inventory = preload("res://scenes/Inventory/ui/inventory/Inventory.tres")
@onready var cross:Sprite2D = $cross
var itemStackGui: ItemStackGui
var index: int

func insertSupplies(isg: ItemStackGui):
	cross.visible = false
	itemStackGui = isg
	container.add_child(itemStackGui)    
	if !itemStackGui.inventorySlot or inventory.supplies_slots[index] == itemStackGui.inventorySlot:
		return
	inventory.insertSlotSupplies(index, itemStackGui.inventorySlot)

func insertGuns(isg: ItemStackGui):
	cross.visible = false
	itemStackGui = isg
	container.add_child(itemStackGui)
	if !itemStackGui.inventorySlot or inventory.guns_slots[index] == itemStackGui.inventorySlot:
		return
	inventory.insertSlotGuns(index, itemStackGui.inventorySlot)

func insertArmors(isg: ItemStackGui):
	cross.visible = false
	itemStackGui = isg
	container.add_child(itemStackGui)
	if !itemStackGui.inventorySlot or inventory.armors_slots[index] == itemStackGui.inventorySlot:
		return
	inventory.insertSlotArmors(index, itemStackGui.inventorySlot)

func takeItemSupplies():
	var item = itemStackGui
	inventory.removeSlotSupplies(itemStackGui.inventorySlot)
	container.remove_child(itemStackGui)
	itemStackGui = null
	cross.visible = true
	return item

func takeItemGuns():
	var item = itemStackGui
	inventory.removeSlotGuns(itemStackGui.inventorySlot)
	container.remove_child(itemStackGui)
	itemStackGui = null
	cross.visible = true
	return item

func takeItemArmors():
	var item = itemStackGui
	inventory.removeSlotArmors(itemStackGui.inventorySlot)
	container.remove_child(itemStackGui)
	itemStackGui = null
	cross.visible = true
	return item

func isEmpty():
	return !itemStackGui
func update_item_position(item: ItemStackGui):
	item.position = container.size / 2 - item.size / 2
func getType():
	return get_parent().get("metadata/type")
