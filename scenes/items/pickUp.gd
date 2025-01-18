extends Area3D

@export var itemRes: InventoryItem

# Параметры для анимации
@export var rotation_speed: float = 30.0  # Скорость вращения в градусах в секунду
@export var rotation_angle: float = 360.0  # Полный угол вращения в градусах
@export var bobbing_amplitude: float = 0.005  # Амплитуда вертикального движения
@export var bobbing_speed: float = 10.0  # Скорость вертикального движения
var start_angle: float = 0.0  # Начальный угол вращения
var target_angle: float = 0.0  # Конечный угол вращения
var current_angle: float = 0.0  # Текущий угол вращения
var rotation_timer: float = 0.0  # Таймер для интерполяции
var bobbing_timer: float = 0.0  # Таймер для вертикального движения

func _ready():
	# Инициализация начального и конечного углов
	start_angle = rotation_degrees.y
	target_angle = start_angle + rotation_angle
	current_angle = start_angle
	rotation_timer = 0.0
	bobbing_timer = 0.0

func _process(delta: float):
	# Выполняем анимацию вращения
	rotation_timer += delta * rotation_speed / rotation_angle
	if rotation_timer > 1.0:
		rotation_timer -= 1.0  # Обнуляем таймер, чтобы вращение повторялось
		# Переключаем начальный и конечный углы
		var temp = start_angle
		start_angle = target_angle
		target_angle = temp

	current_angle = lerp(start_angle, target_angle, rotation_timer)
	rotation_degrees.y = current_angle

	# Выполняем вертикальное движение (боббинг)
	bobbing_timer += delta * bobbing_speed
	position.y += bobbing_amplitude * sin(bobbing_timer)

func collect(inventory: Inventory):
	var can_collect = true  #е Initialize a flag to determine if the item can be collected

	if itemRes.type == "Supplies":
		can_collect = not inventory.isSuppliesFull()
	elif itemRes.type == "Guns":
		can_collect = not inventory.isGunsFull()
	elif itemRes.type == "Armor":
		can_collect = not inventory.isArmorsFull()

	if can_collect:
		if itemRes.type == "Supplies":
			inventory.insertSupplies(itemRes)
		elif itemRes.type == "Guns":
			inventory.insertGuns(itemRes)
		elif itemRes.type == "Armor":
			inventory.insertArmors(itemRes)
		queue_free()  # Free the item only if it was successfully collected
	else:
		print("Cannot collect item. Inventory is full.")
