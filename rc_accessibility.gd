extends RefCounted
class_name RCAccessibility

static func defaults() -> Dictionary:
    return {
        "ui_scale": 1.0,
        "large_touch_targets": true,
        "high_contrast": false,
        "reduced_motion": false,
        "handed_layout": "Right"
    }

static func clamp_scale(value: float) -> float:
    return clamp(value, 0.85, 1.50)
