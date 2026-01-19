extends CharacterBody2D

@export var 중력가속도 = 700
@export var 점프속도 = -400
@export var 이동속도 = 300
@export var 사다리속도 = 200
@export var last_dir = 0
@export var on_ladder = false
@export var is_climbing = false
@export var desired_x_pos: float
@export var is_attacking = false
@export var is_damaged = false
@onready var 스프라이트 = $"기본Body"
@onready var 머리 = $"머리"
@onready var 상의 = $"상의"
@onready var 하의 = $"하의"
@onready var ladder_layer: TileMapLayer = $"../ladder"
@export var HP = 130
@export var MP = 100
@export var EXP = 10
var climb_move = "사다리이동"
var climb_idle = "사다리정지"


func _physics_process(delta):

	_movement(delta)
	move_and_slide()
	
	

func _movement(delta):
	# 캐릭터가 바닥에 있지 않은 경우에만 중력 적용
	if not is_on_floor():
		velocity.y += delta * 중력가속도
	
	if is_damaged:
		velocity.x = 0  # 가로 속도 고정 (밀려나는 연출 넣고 싶으면 여기서만 조절)
		return
	
	if is_on_floor():
		is_climbing = false
	
	# --- 사다리 시작(타일 직접 검사): 위/아래 키를 "처음" 눌렀을 때 ---
	if not is_climbing:
		if Input.is_action_just_pressed("ui_up"):
			#pass
			_try_start_climb(1)    # 위로 시작
		elif Input.is_action_just_pressed("ui_down"):
			#pass
			_try_start_climb(-1)   # 아래로 시작(발밑 셀 검사)
	
	# --- 사다리 이동 중 ---
	if is_climbing:
		# X를 항상 중앙에 고정
		global_position.x = desired_x_pos
		
		# 수평 이동 막기
		velocity.x = 0
		last_dir = 0

		# 사다리 중 좌우 방향 결정
		if Input.is_action_pressed("좌"):
			last_dir = -1
		elif Input.is_action_pressed("우"):
			last_dir = 1
		
		# 수직 이동만 처리
		if Input.is_action_pressed("ui_down"):
			velocity.y = 사다리속도
			스프라이트.play(climb_move)
			머리.play(climb_move)
			상의.play(climb_move)
			하의.play(climb_move)
		elif Input.is_action_pressed("ui_up"):
			velocity.y = -사다리속도
			스프라이트.play(climb_move)
			머리.play(climb_move)
			상의.play(climb_move)
			하의.play(climb_move)
		else:
			velocity.y = 0
			스프라이트.play(climb_idle)
			머리.play(climb_idle)
			상의.play(climb_idle)
			하의.play(climb_idle)

	else:
		# 평상시 이동 로직
		if Input.is_action_just_pressed("좌"):
			last_dir = -1
		elif Input.is_action_just_pressed("우"):
			last_dir = 1

		if Input.is_action_just_released("좌") and last_dir == -1:
			last_dir = 1 if Input.is_action_pressed("우") else 0
		elif Input.is_action_just_released("우") and last_dir == 1:
			last_dir = -1 if Input.is_action_pressed("좌") else 0
		velocity.x = last_dir * 이동속도
	
	if Input.is_action_just_pressed("점프"):
		on_ladder = false
		is_climbing = false
		print(last_dir)
		velocity.x = last_dir * 이동속도
		velocity.y = 점프속도
	
	# 애니메이션
	# 애니메이션 좌우 설정
	if last_dir == 1:
		스프라이트.flip_h = false
		머리.flip_h = false
		상의.flip_h = false
		하의.flip_h = false
	elif last_dir == -1:
		스프라이트.flip_h = true
		머리.flip_h = true
		상의.flip_h = true
		하의.flip_h = true
	
	if Input.is_action_just_pressed("공격") and not is_climbing:
		is_attacking = true
		스프라이트.play("펀치")
		머리.play("펀치")
		상의.play("펀치")
		하의.play("펀치")
		await 스프라이트.animation_finished
		is_attacking = false
	
	if !is_attacking and !is_damaged:
		# 캐릭터가 바닥에 있을 때
		if is_on_floor() == true:
			if velocity.x == 0:
				스프라이트.play("서있기")
				머리.play("서있기")
				상의.play("서있기")
				하의.play("서있기")
			else:
				스프라이트.play("걷기")
				머리.play("걷기")
				상의.play("걷기")
				하의.play("걷기")
		# 캐릭터가 바닥에 있지 않을 때
		else:
			if is_climbing:
				pass
					
			else:
				if velocity.y > 0:
					스프라이트.play("떨어지기")
					머리.play("떨어지기")
					상의.play("떨어지기")
					하의.play("떨어지기")
				elif velocity.y < 0:
					스프라이트.play("점프")
					머리.play("점프")
					상의.play("점프")
					하의.play("점프")

func _try_start_climb(dir: int) -> void:
	# 기준 위치: 위로 시작은 현재, 아래로 시작은 발밑 오프셋
	var pos_g := global_position
	if dir < 0:
		var cell_size := ladder_layer.tile_set.tile_size
		pos_g.y += float(cell_size.y) * 2
	
	if dir > 0:
		var cell_size := ladder_layer.tile_set.tile_size
		pos_g.y -= float(cell_size.y) * 2

	var pos_local := ladder_layer.to_local(pos_g)
	var cell := ladder_layer.local_to_map(pos_local)

	var td := ladder_layer.get_cell_tile_data(cell)
	if td != null and td.get_custom_data("is_ladder") == true:
		if td.get_custom_data("ladder")==true:
			_start_climb_at_cell(cell, dir, "ladder")
		elif td.get_custom_data("rope")==true:
			_start_climb_at_cell(cell, dir, "rope")

func _start_climb_at_cell(cell: Vector2i, dir: int, ladder_or_rope: String) -> void:
	var center_local := ladder_layer.map_to_local(cell)
	var center_global := ladder_layer.to_global(center_local)
	desired_x_pos = center_global.x
	global_position.x = desired_x_pos
	global_position.y += 1
	is_climbing = true
	if ladder_or_rope == "ladder":
		climb_move = "사다리이동"
		climb_idle = "사다리정지"
	elif ladder_or_rope == "rope":
		climb_move = "로프이동"
		climb_idle = "로프정지"

func _on_body_entered(body: Node2D) -> void:
	on_ladder = true
	print("사다리 발견")
	
func _on_body_exited(body: Node2D) -> void:
	on_ladder = false
	is_climbing = false
	스프라이트.play("서있기")
	머리.play("서있기")
	상의.play("서있기")
	하의.play("서있기")

func _on_피격_body_entered(body: Node2D) -> void:
	
	is_damaged = true
	is_attacking = false
	velocity = Vector2.ZERO
	last_dir = 0
	HP-=12
	print("공격 당함 (-12)")
	스프라이트.play("공격당함")
	머리.play("공격당함")
	상의.play("공격당함")
	하의.play("공격당함")
	await 스프라이트.animation_finished
	is_damaged = false
	if !is_damaged:
		_서있기()

func _on_피격_body_exited(body: Node2D) -> void:
	if is_damaged== true:
		is_damaged = false
	

func _서있기():
	스프라이트.play("서있기")
	머리.play("서있기")
	상의.play("서있기")
	하의.play("서있기")
	
#func _걷기():
	#스프라이트.play("걷기")
	#머리.play("걷기")
	#상의.play("걷기")
	#하의.play("걷기")

func _펀치():
	스프라이트.play("펀치")


#트램폴린 함수
func 강제점프(강도):
	velocity.y = 점프속도 * 강도



#물과 스파이크를 처리하기 위해 GPT가 만든 함수
func 체력감소(체력) :
	HP -= 체력
	print("체력 감소 (-" + str(체력) + ")")
	스프라이트.play("공격당함")
	머리.play("공격당함")
	상의.play("공격당함")
	하의.play("공격당함")
	await 스프라이트.animation_finished
	is_damaged = false
	if !is_damaged:
		_서있기()

	
	
func _on_데미지_body_entered(body: Node2D) -> void:
	if body == self:
		var parent = get_parent()
		var damage_amount := 10  # 기본값

		# 데미지 Area2D에서 설정된 값 가져오기
		if "damage_amount" in parent:
			damage_amount = parent.damage_amount

		print("데미지 존에 닿음! 피해량:", damage_amount)
		체력감소(damage_amount)


#장애물 설정을 위해 인프런을 보고 만든 함수
func 체력깎임(얼마나):
	Global.체력 -= 얼마나
	if Global.체력 <= 0:
		print("죽었습니다")
	else:
		Global.체력 -= 얼마나
		
	
	
