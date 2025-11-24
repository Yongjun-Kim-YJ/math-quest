extends Area2D

@export var 다음레벨: PackedScene = null
var 포탈안 = false
var player: CharacterBody2D = null

func _on_캐릭터충돌판정_body_entered(body):
	if body.name == "캐릭터":
		포탈안 = true
		player = body
		print("포탈 범위 진입")

func _on_캐릭터충돌판정_body_exited(body):
	if body.name == "캐릭터":
		포탈안 = false
		player = null
		print("포탈 범위 이탈")

func _physics_process(delta):
	if 포탈안 and Input.is_action_just_pressed("ui_up") and player and player.is_on_floor():
		print("포탈 활성화")
		if 다음레벨:
			get_tree().change_scene_to_packed(다음레벨)
