extends Minigame

const DODGEBALL_SCENE: PackedScene = preload("res://minigames/dodgeball/dodgeball.tscn")
const BASE_SPAWN_INTERVAL: float = 1.0
const SPAWN_MARGIN: int = 50
const TRACKING_PROBABILITY: float = 0.6
const TRACKING_INACCURACY: float = 0.3

var spawn_timer: Timer

@onready var player: CharacterBody2D = $Player
@onready var result_label: Label = $ResultLabel

func start():
	countdown_time += difficulty * 2.0
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = BASE_SPAWN_INTERVAL / difficulty
	spawn_timer.timeout.connect(_spawn_dodgeball)
	add_child(spawn_timer)
	spawn_timer.start()
	
	var viewport_size = get_viewport().get_visible_rect().size
	player.position = viewport_size / 2.0
	result_label.visible = false

func run():
	if countdown_timer.time_left <= 0.1 and not has_ended:
		win()
		_show_result("You Survived!")

func _spawn_dodgeball():
	var dodgeball: Area2D = DODGEBALL_SCENE.instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	
	var spawn_pos = _get_random_edge_position(viewport_size)
	var direction = _calculate_direction(spawn_pos)
	
	dodgeball.position = spawn_pos
	dodgeball.speed = 200.0 * sqrt(difficulty)
	dodgeball.set_direction(direction)
	add_child(dodgeball)

func _get_random_edge_position(viewport_size: Vector2) -> Vector2:
	var edge = randi() % 4
	var random_x = randf_range(0, viewport_size.x)
	var random_y = randf_range(0, viewport_size.y)
	
	var positions = [
		Vector2(random_x, -SPAWN_MARGIN),
		Vector2(viewport_size.x + SPAWN_MARGIN, random_y),
		Vector2(random_x, viewport_size.y + SPAWN_MARGIN),
		Vector2(-SPAWN_MARGIN, random_y)
	]
	
	return positions[edge]

func _calculate_direction(spawn_pos: Vector2) -> Vector2:
	var direction: Vector2
	
	if randf() < TRACKING_PROBABILITY:
		direction = (player.global_position - spawn_pos).normalized()
		direction = direction.rotated(randf_range(-TRACKING_INACCURACY, TRACKING_INACCURACY))
	else:
		var angle_to_center = spawn_pos.angle_to_point(get_viewport().get_visible_rect().size / 2.0)
		var random_offset = randf_range(-0.5, 0.5)
		direction = Vector2.from_angle(angle_to_center + random_offset)
	
	return direction

func player_hit():
	if not has_ended:
		lose()
		spawn_timer.stop()
		_show_result("You Died!")

func end():
	spawn_timer.stop()
	for child in get_children():
		if child is Area2D:
			child.queue_free()

func _show_result(message: String):
	result_label.text = message
	result_label.visible = true

