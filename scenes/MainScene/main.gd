extends Node

const port = 135
@onready var ip_text = $CanvasLayer/Control/HBoxContainer/Control3/LineEdit
func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	start_game()


func _on_join_pressed():
	var ip = ip_text.text
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	$CanvasLayer.visible=false
	$CanvasLayer/Control/SubViewportContainer/SubViewport/Lobby.visible=false
	if multiplayer.is_server():
		change_level.call_deferred(preload("res://scenes/Polygon/Polygon.tscn"))
	pass

func change_level(scene:PackedScene):
	var level = $Levels
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())
	pass
