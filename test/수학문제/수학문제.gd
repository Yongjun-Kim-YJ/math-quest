extends Area2D

@onready var 스프라이트: AnimatedSprite2D = $AnimatedSprite2D

var 접근: bool = false
var 열림: bool = false
var 문제UI: Control = null
var solved: bool = false

@export var 문제UI씬: PackedScene
@export var 문제이미지: Texture2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "캐릭터":
		print("수학문제 접근")
		접근 = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "캐릭터" and not solved:
		print("수학문제 멀어짐")
		스프라이트.play("기본")
		접근 = false
		열림 = false
		_close_problem_ui()

func _physics_process(_delta: float) -> void:
	# 열기
	if 접근 and not 열림 and Input.is_action_just_pressed("ui_up"):
		열림 = true
		스프라이트.play("열림")
		print("열림")
		_show_problem_ui()

	if 열림:
		# 정답
		if Input.is_action_just_pressed("7"):
			solved = true
			print("정답")
			_close_problem_ui()
			스프라이트.play("닫힘")
			await 스프라이트.animation_finished
			queue_free()
		# 오답
		elif Input.is_action_just_pressed("1") or Input.is_action_just_pressed("2") or Input.is_action_just_pressed("3") or Input.is_action_just_pressed("4") or Input.is_action_just_pressed("5") or Input.is_action_just_pressed("6") or Input.is_action_just_pressed("8") or Input.is_action_just_pressed("9") or Input.is_action_just_pressed("0"):
			print("오답")
			_close_problem_ui()
			스프라이트.play("기본")
			열림 = false

func _show_problem_ui() -> void:
	if not 문제UI씬:
		push_warning("문제UI씬이 설정되지 않았습니다.")
		return
	if 문제UI and is_instance_valid(문제UI):
		return # 이미 열림
	문제UI = 문제UI씬.instantiate()
	# 이미지 주입 (set_image 메서드 있으면 사용)
	if 문제이미지:
		if 문제UI.has_method("set_image"):
			문제UI.call("set_image", 문제이미지)
		elif 문제UI.has_node("MarginContainer/TextureRect"):
			문제UI.get_node("MarginContainer/TextureRect").texture = 문제이미지

	# 최상위에 붙여 항상 화면 위에 보이게
	get_tree().root.add_child(문제UI)
	문제UI.move_to_front()

func _close_problem_ui() -> void:
	
	if 문제UI and is_instance_valid(문제UI):
		var ui := 문제UI
		문제UI = null  # 중복 호출/경합 방지

		if ui.is_queued_for_deletion():
			return

		# 간단 페이드아웃
		var tw := ui.create_tween()
		tw.tween_property(ui, "modulate:a", 0.0, 0.25) \
		  .set_trans(Tween.TRANS_SINE) \
		  .set_ease(Tween.EASE_IN_OUT)

		await tw.finished
		if is_instance_valid(ui):
			ui.queue_free()
