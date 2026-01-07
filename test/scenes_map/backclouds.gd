extends Sprite2D

@export var scroll_speed := Vector2(-15, 0)

func _process(delta):
	position += scroll_speed * delta

	if position.x > get_viewport_rect().size.x + texture.get_size().x / 2:
		position.x = -texture.get_size().x / 2
