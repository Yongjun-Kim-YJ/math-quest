# Detected by HitArea2D
@icon("hit_area_2d.svg")
class_name HitArea2D extends Area2D

@export var damage := 10

func _init() -> void:
	collision_layer = 32
	collision_mask = 0

#func _ready() -> void:
	## This turns off collision mask bit 1 and turns on bit 2. It's the physics layer we reserve to hurtboxes in this demo.
	#collision_layer = 32
	#collision_mask = 0

#func get_damage() -> int:
	#return damage + randi() % 7 - 3
