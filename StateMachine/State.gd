# State.gd
extends Node

class_name State

# Состояние игрока
var nameSt: String

# Функция для входа в состояние
func enter(owners: Node3D):
	pass

# Функция для выхода из состояния
func exit(owners: Node3D):
	pass

# Функция для обновления состояния
func update(owners: Node3D, delta: float):
	pass
