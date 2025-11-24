#extends Control
#
#@export var 문제이미지: Texture
#
#@onready var image_rect := $TextureRect
#
#func _ready():
	#if 문제이미지:
		#image_rect.texture = 문제이미지
#
#func _on_Button_pressed():
	#queue_free()

extends Control

@export var 문제이미지: Texture2D

@onready var image_rect: TextureRect = $TextureRect

func _ready():
	# UI가 입력을 가로채지 않게 하려면(키 입력은 기존 코드에서 처리):
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if 문제이미지:
		image_rect.texture = 문제이미지
	# 간단한 페이드인
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.15)

func set_image(tex: Texture2D) -> void:
	문제이미지 = tex
	if is_instance_valid(image_rect):
		image_rect.texture = tex
