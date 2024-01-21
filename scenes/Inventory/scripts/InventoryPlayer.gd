extends Control

@onready var inv_items:Slots_items= preload("res://scenes/Inventory/inv_slots/inv_items/slot_items.tres")
@onready var inv_armors:Slots  = preload("res://scenes/Inventory/inv_slots/inv_armors/slot_armors.tres")
@onready var inv_guns:Slots = preload("res://scenes/Inventory/inv_slots/inv_guns/slot_guns.tres")

@onready var items:Array =$NinePatchRect/HBoxContainer/Control/GridContainer1.get_children()
@onready var armors:Array =$NinePatchRect/HBoxContainer/Control2/GridContainer2.get_children()
@onready var guns:Array =$NinePatchRect/HBoxContainer/Control3/GridContainer3.get_children()

var is_open = false

func _ready():
	inv_items.update.connect(update_items)
	inv_armors.update.connect(update_armors)
	inv_guns.update.connect(update_guns)
	update_items()
	update_armors()
	update_guns()
	close()

func update_items():

	for i in range(min(inv_items.slots.size(),items.size())):
		items[i].update(inv_items.slots[i])
	
		
func update_armors():

	for i in range(min(inv_armors.slots.size(),armors.size())):
		armors[i].update(inv_armors.slots[i])
		
		
func update_guns():

	for i in range(min(inv_guns.slots.size(),guns.size())):
		guns[i].update(inv_guns.slots[i])
		

func open():
	visible=true
	is_open=true

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func close():
	visible= false
	is_open=false
