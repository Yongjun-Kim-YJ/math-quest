# Allows its owner to detect hits and take damage
@icon("hurt_area_2d.svg")
class_name HurtArea2D extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 32

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	#connect("area_entered", self, "_on_area_entered")
	## The hurtbox should detect hits but not deal them. This variable does that.
	#monitorable = false
	## This turns off collision layer bit 1 and turns on bit 2. It's the physics layer we reserve to hurtboxes in this demo.
	#collision_mask = 32
	#collision_layer = 32


func _on_area_entered(hit_area: HitArea2D) -> void:
	if hit_area == null:
		return

	if owner.has_method("take_damage"):
		owner.take_damage(hit_area.damage)

	#if owner.has_method("knock_back"):
		#owner.knock_back(hit_area.global_position)
