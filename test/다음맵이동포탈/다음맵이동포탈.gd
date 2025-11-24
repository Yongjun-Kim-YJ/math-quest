extends StaticBody2D

@onready var 스프라이트 = $AnimatedSprite2D

@export var 다음레벨:PackedScene = null

func _on_캐릭터충돌판정_body_entered(body):
	if body.name == "캐릭터":
		스프라이트.play("활성화")
		get_tree().change_scene_to_packed(다음레벨)
