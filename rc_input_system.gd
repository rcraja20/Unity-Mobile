extends Node
class_name RCInputSystem

signal tap(position: Vector2)
signal double_tap(position: Vector2)
signal long_press(position: Vector2)
signal drag(delta: Vector2)
signal pinch(scale_delta: float)
signal two_finger_pan(delta: Vector2)

var _touches: Dictionary = {}
var _press_time: Dictionary = {}
var _last_tap_time := -1.0
var _last_tap_position := Vector2.ZERO
var long_press_seconds := 0.55
var double_tap_seconds := 0.30
var double_tap_distance := 48.0

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _touches[event.index] = event.position
            _press_time[event.index] = Time.get_ticks_msec() / 1000.0
        else:
            var start: Vector2 = _touches.get(event.index, event.position)
            var elapsed := Time.get_ticks_msec() / 1000.0 - float(_press_time.get(event.index, 0.0))
            _touches.erase(event.index)
            _press_time.erase(event.index)
            if elapsed >= long_press_seconds:
                long_press.emit(event.position)
            elif Time.get_ticks_msec() / 1000.0 - _last_tap_time <= double_tap_seconds and event.position.distance_to(_last_tap_position) <= double_tap_distance:
                double_tap.emit(event.position)
                _last_tap_time = -1.0
            else:
                tap.emit(event.position)
                _last_tap_time = Time.get_ticks_msec() / 1000.0
                _last_tap_position = event.position
    elif event is InputEventMagnifyGesture:
        pinch.emit(event.factor, event.position)
    elif event is InputEventPanGesture:
        two_finger_pan.emit(event.delta, event.position)
    elif event is InputEventScreenDrag:
        drag.emit(event.relative)
    elif event is InputEventMouseMotion and event.button_mask != 0:
        drag.emit(event.relative)
