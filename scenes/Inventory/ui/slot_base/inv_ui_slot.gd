extends Panel
class_name inv_base
@onready var item_display:TextureRect = get_node_or_null("CenterContainer/Panel/item_display")

var is_hover = false


func update(slot:InvSlot):
	
	pass

func _get_drag_data(at_position):

	pass 

func _can_drop_data(at_position, data):
	pass 

func _drop_data(at_position, data):
	pass
