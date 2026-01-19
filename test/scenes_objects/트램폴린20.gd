extends Area2D

@onready var 스프라이트 = $"트램폴린20"


func _on_body_entered(body: Node2D) -> void:
	if body.name == "캐릭터":
		스프라이트.play("튀어오르기20")
		body.강제점프(2)
		
		
