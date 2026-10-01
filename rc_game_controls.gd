extends Node
class_name RCGameControls

var move_vector := Vector2.ZERO
var look_vector := Vector2.ZERO
var sprint := false

func set_move(value: Vector2) -> void:
    move_vector = value.limit_length(1.0)

func set_look(value: Vector2) -> void:
    look_vector = value

func set_sprint(value: bool) -> void:
    sprint = value

func reset() -> void:
    move_vector = Vector2.ZERO
    look_vector = Vector2.ZERO
    sprint = false
