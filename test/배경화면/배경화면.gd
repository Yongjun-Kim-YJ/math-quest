extends ParallaxBackground

@export var 배경이미지:CompressedTexture2D
@export var 스크롤속도X = 10
@export var 스크롤속도Y = 10
@onready var 스프라이트 = $ParallaxLayer/Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	스프라이트.texture = 배경이미지


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	스프라이트.region_rect.position.x += delta * 스크롤속도X
	스프라이트.region_rect.position.y += delta * 스크롤속도Y

	if 	스프라이트.region_rect.position.x >= 1024:
		스프라이트.region_rect.position = Vector2.ZERO
