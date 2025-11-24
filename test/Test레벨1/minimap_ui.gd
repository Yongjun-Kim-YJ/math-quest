extends CanvasLayer

@export var player_path: NodePath
@onready var svp: SubViewport = $SubViewportContainer/SubViewport
@onready var cam: Camera2D = $SubViewportContainer/SubViewport/MinimapCamera2D
var player: Node2D

func _ready():
	player = get_node(player_path)
	# 메인 월드 공유해서 현재 맵 그대로 렌더
	svp.world_2d = get_viewport().world_2d
	cam.zoom = Vector2(0.25, 0.25) # 더 넓게 보려면 더 작게

func _process(_dt):
	if player:
		cam.global_position = player.global_position
		# 플레이어 기준 회전 미니맵을 원하면:
		# cam.rotation = -player.global_rotation
