extends CharacterBody2D

@export var stats: Stats
@export var 중력가속도 = 1000
@export var 이동속도 = 100
@onready var 스프라이트 = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
var 피격가능 = false
var 체력 = 1000
var 사망 = false

func take_damage(amount: int) -> void:
	#animation_player.play("hit")
	print("Damage: ", amount)
	체력-=amount
	$TextureProgressBar.value -=amount/체력
	

func _physics_process(delta):
	# 캐릭터가 바닥에 있지 않은 경우에만 중력 적용
	if is_on_floor() == false:
		velocity.y += delta * 중력가속도
		#
	if 체력<=0 and !사망:
		사망 = true
		print("사망체력")
		print(체력)
		스프라이트.play("사망")
		velocity.x = 0
		print("3333333")
		await 스프라이트.animation_finished
		self.queue_free()
	if 피격가능 and Input.is_action_just_pressed("공격"):
		take_damage(0)
		스프라이트.play("공격당함")
		체력-=34
		$TextureProgressBar.value = 체력
		velocity.x = 0
		스프라이트.flip_h = false
		print("1111111")
		await 스프라이트.animation_finished
		스프라이트.play("달리기")
		velocity.x = -이동속도
		print(체력)
	
	move_and_slide()

func _on_캐릭터감지범위_body_entered(body: Node2D) -> void:
	if body.name == "캐릭터":
		if (body.global_position.x - self.global_position.x) < 0:
			# 캐릭터가 몬스터 왼쪽에 있음
			스프라이트.flip_h = false
			스프라이트.play("달리기")
			velocity.x = -이동속도
		else:
			# 캐릭터가 몬스터 오른쪽에 있음
			스프라이트.flip_h = true
			스프라이트.play("달리기")
			velocity.x = +이동속도


func _on_피격범위_body_entered(body: Node2D) -> void:
	if body.name == "캐릭터":
		피격가능 = true
		print("피격가능")
		##if body.공격상태 == true:
			#스프라이트.play("공격당함")
			#velocity.x = 0
			#await 스프라이트.animation_finished
			#스프라이트.flip_h = false
			#스프라이트.play("달리기")
			#velocity.x = -이동속도
			#await 스프라이트.animation_finished
			#스프라이트.play("공격당함")
			#velocity.x = 0
			#await 스프라이트.animation_finished
			#self.queue_free()

func _on_피격범위_body_exited(body: Node2D) -> void:
	if body.name == "캐릭터":
		피격가능 = false
		print("피격불가능")
