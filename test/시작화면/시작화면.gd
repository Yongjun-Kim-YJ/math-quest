extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_게임_시작_버튼_pressed() -> void:
	#get_tree().change_scene_to_file("res://레벨_0/레벨_0.tscn")
	get_tree().change_scene_to_file("res://Test레벨1/테스트레벨1.tscn")
