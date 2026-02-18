extends CharacterBody2D

# =============================================
# character.gd를 100% 복사한 후 필요한 부분만 수정
# =============================================

# --- 기본 설정 ---
@export var 중력가속도 = 700
@export var 점프속도 = -420  # 요청: -420으로 변경
@export var 기본_이동속도 = 300  # 요청: 300의 30% = 90
@export var 사다리속도 = 200
@export var last_dir = 0
@export var on_ladder = false
@export var is_climbing = false
@export var desired_x_pos: float
@export var is_attacking = false
@export var is_damaged = false

# --- 레벨 시스템 추가 ---
var 현재레벨: int = 1
var 현재경험치: int = 0
var 최대체력: int = 100
var 현재체력: int = 100
var 현재공격력: int = 10

# 레벨업에 필요한 경험치
func 필요경험치() -> int:
	return 현재레벨 * 100

# 레벨에 따른 이동속도 (레벨당 5% 증가)
var 이동속도: float:
	get:
		return 기본_이동속도 * (1.0 + (현재레벨 - 1) * 0.05)

# 대시 해금 (레벨 5)
var 대시_해금: bool:
	get:
		return 현재레벨 >= 5

# 더블점프 해금 (레벨 10)
var 더블점프_해금: bool:
	get:
		return 현재레벨 >= 10

# --- 점프 관련 ---
var jump_count: int = 0
var max_jump_count: int:
	get:
		return 2 if 더블점프_해금 else 1

# --- 대시 관련 ---
var is_dashing: bool = false
var dash_speed: float = 500.0
var dash_duration: float = 0.2
var dash_timer: float = 0.0
var dash_cooldown: float = 1.0
var dash_cooldown_timer: float = 0.0

# --- 노드 참조 (요청: 바디, 헤어로 변경) ---
@onready var 바디 = $HeroBody
@onready var 헤어 = $hair0
@onready var ladder_layer: TileMapLayer = $"../ladder"

# --- 사다리 애니메이션 (요청: s18, s19로 변경) ---
var climb_move = "s18"
var climb_idle = "s18"


func _ready() -> void:
	현재체력 = 최대체력
	print("=== 히어로 초기화 ===")
	print("레벨: ", 현재레벨)
	print("체력: ", 현재체력, "/", 최대체력)
	print("이동속도: ", 이동속도)


func _physics_process(delta):
	_movement(delta)
	move_and_slide()
	
	# 바닥에 닿으면 점프 초기화
	if is_on_floor():
		jump_count = 0
	
	# 대시 타이머
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false


# =============================================
# character.gd의 _movement 함수 100% 복사
# =============================================
func _movement(delta):
	# 캐릭터가 바닥에 있지 않은 경우에만 중력 적용
	if not is_on_floor():
		velocity.y += delta * 중력가속도
	
	if is_damaged:
		velocity.x = 0  # 가로 속도 고정 (밀려나는 연출 넣고 싶으면 여기서만 조절)
		return
	
	if is_on_floor():
		is_climbing = false
	
	# --- 사다리 시작(타일 직접 검사): 위/아래 키를 누르고 있을 때 + 사다리 타일 위에 있을 때 ---
	if not is_climbing:
		# 위 방향키: 누르고 있으면 위로 올라가기 시도
		if Input.is_action_pressed("ui_up"):
			_try_start_climb(1)    # 위로 시작
		# 아래 방향키: 누르고 있으면 아래로 내려가기 시도
		elif Input.is_action_pressed("ui_down"):
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
			바디.play(climb_move)
			헤어.play(climb_move)
		elif Input.is_action_pressed("ui_up"):
			velocity.y = -사다리속도
			바디.play(climb_move)
			헤어.play(climb_move)
		else:
			velocity.y = 0
			바디.play(climb_idle)
			헤어.play(climb_idle)

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
		
		# 대시 중이면 대시 속도
		if is_dashing:
			velocity.x = last_dir * dash_speed
		else:
			velocity.x = last_dir * 이동속도
	
	# --- 점프 (수정: 더블점프 지원) ---
	if Input.is_action_just_pressed("점프"):
		if is_climbing:
			on_ladder = false
			is_climbing = false
			print(last_dir)
			velocity.x = last_dir * 이동속도
			velocity.y = 점프속도
		elif jump_count < max_jump_count:
			velocity.y = 점프속도
			jump_count += 1
	
	# --- 대시 (레벨 5부터) ---
	if 대시_해금 and Input.is_action_just_pressed("ui_shift") and not is_dashing and dash_cooldown_timer <= 0:
		if last_dir != 0:
			is_dashing = true
			dash_timer = dash_duration
			dash_cooldown_timer = dash_cooldown
			print("대시!")
	
	# 애니메이션
	# 애니메이션 좌우 설정
	if last_dir == 1:
		바디.flip_h = false
		헤어.flip_h = false
	elif last_dir == -1:
		바디.flip_h = true
		헤어.flip_h = true
	
	# --- V키 공격 ---
	if Input.is_action_just_pressed("ui_attack_v") and not is_climbing:
		is_attacking = true
		바디.play("s22")
		헤어.play("s22")
		print("V 공격! 공격력: ", 현재공격력)
		await 바디.animation_finished
		is_attacking = false
	
	if !is_attacking and !is_damaged:
		# 캐릭터가 바닥에 있을 때
		if is_on_floor() == true:
			if velocity.x == 0:
				바디.play("s09")  # idle
				헤어.play("s09")
			else:
				if is_dashing:
					바디.play("s16")  # run
					헤어.play("s16")
				else:
					바디.play("s15")  # walk
					헤어.play("s15")
		# 캐릭터가 바닥에 있지 않을 때
		else:
			if is_climbing:
				pass
					
			else:
				if velocity.y > 0:
					바디.play("s10down")  # 떨어지기
					헤어.play("s10down")
				elif velocity.y < 0:
					바디.play("s10up")  # 점프
					헤어.play("s10up")


# =============================================
# character.gd의 사다리 함수 100% 복사
# =============================================
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
		climb_move = "s18"
		climb_idle = "s18"
	elif ladder_or_rope == "rope":
		climb_move = "s19"
		climb_idle = "s19"


# =============================================
# Area2D 신호
# =============================================
func _on_body_entered(body: Node2D) -> void:
	on_ladder = true
	print("사다리 발견")
	
func _on_body_exited(body: Node2D) -> void:
	on_ladder = false
	is_climbing = false
	바디.play("s09")
	헤어.play("s09")


# =============================================
# 피격 처리
# =============================================
func _on_피격_body_entered(body: Node2D) -> void:
	is_damaged = true
	is_attacking = false
	velocity = Vector2.ZERO
	last_dir = 0
	현재체력 -= 12
	print("공격 당함 (-12), 남은 체력: ", 현재체력)
	바디.play("s02")
	헤어.play("s02")
	await 바디.animation_finished
	is_damaged = false
	if !is_damaged:
		_서있기()
	
	if 현재체력 <= 0:
		print("사망!")

func _on_피격_body_exited(body: Node2D) -> void:
	if is_damaged== true:
		is_damaged = false


# =============================================
# 유틸리티 함수
# =============================================
func _서있기():
	바디.play("s09")
	헤어.play("s09")

func 강제점프(강도):
	velocity.y = 점프속도 * 강도

func 체력감소(체력) :
	현재체력 -= 체력
	print("체력 감소 (-" + str(체력) + "), 남은 체력: ", 현재체력)
	바디.play("s02")
	헤어.play("s02")
	await 바디.animation_finished
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


# =============================================
# 레벨 시스템
# =============================================
func 경험치획득(amount: int) -> void:
	현재경험치 += amount
	print("경험치 +", amount, " (", 현재경험치, "/", 필요경험치(), ")")
	
	while 현재경험치 >= 필요경험치():
		레벨업()

func 레벨업() -> void:
	현재경험치 -= 필요경험치()
	현재레벨 += 1
	
	최대체력 = min(10000, 최대체력 + 50)
	현재체력 = 최대체력
	현재공격력 += 5
	
	print("★★★ 레벨업! ★★★")
	print("레벨: ", 현재레벨)
	print("체력: ", 현재체력, "/", 최대체력)
	print("이동속도: ", 이동속도)
	print("공격력: ", 현재공격력)
	
	if 현재레벨 == 5:
		print("★ 대시 해금!")
	if 현재레벨 == 10:
		print("★ 더블점프 해금!")
