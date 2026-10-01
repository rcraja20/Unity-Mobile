extends Node3D
class_name RCEditableScene

@export var grid_size := 1.0
var selected: Node3D

func select_node(node: Node3D) -> void:
    selected = node

func move_selected(delta: Vector3) -> void:
    if selected:
        selected.position += delta

func rotate_selected(delta: Vector3) -> void:
    if selected:
        selected.rotation += delta

func scale_selected(factor: Vector3) -> void:
    if selected:
        selected.scale *= factor

func focus_selected() -> void:
    if selected:
        var camera := get_viewport().get_camera_3d()
        if camera:
            camera.look_at(selected.global_position, Vector3.UP)
