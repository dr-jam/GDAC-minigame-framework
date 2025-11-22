extends Area2D

var velocity: Vector2
var speed: float = 200.0

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	position += velocity * delta
	
	var viewport_size = get_viewport().get_visible_rect().size
	if position.x < -100 or position.x > viewport_size.x + 100 or \
	   position.y < -100 or position.y > viewport_size.y + 100:
		queue_free()

func _on_body_entered(body):
	if body is CharacterBody2D:
		var parent = get_parent()
		if parent and parent.has_method("player_hit"):
			parent.player_hit()
		queue_free()

func set_direction(direction: Vector2):
	velocity = direction.normalized() * speed

