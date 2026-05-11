class_name BoardZone
extends Area2D

enum Team {PLAYER, ENEMY}

@export var team: Team = Team.PLAYER

func _ready() -> void:
	add_to_group("board_zone")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func get_rect() -> Rect2:
	var shape = $CollisionShape
	var ext = (shape.shape as RectangleShape2D).size / 2
	return Rect2(global_position - ext, ext * 2)
