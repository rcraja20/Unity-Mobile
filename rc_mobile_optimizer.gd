extends RefCounted
class_name RCMobileOptimizer

static func presets() -> Dictionary:
    return {
        "LOW": {"resolution_scale":0.70,"fps":30,"shadows":false,"textures":"Low","effects":"Low","view_distance":"Near","lod":"Aggressive"},
        "MEDIUM": {"resolution_scale":0.85,"fps":45,"shadows":true,"textures":"Medium","effects":"Medium","view_distance":"Normal","lod":"Balanced"},
        "HIGH": {"resolution_scale":1.00,"fps":60,"shadows":true,"textures":"High","effects":"High","view_distance":"Far","lod":"Quality"},
        "ULTRA": {"resolution_scale":1.00,"fps":60,"shadows":true,"textures":"Ultra","effects":"Ultra","view_distance":"Very Far","lod":"Quality"}
    }

static func apply_preset(name: String) -> Dictionary:
    var all := presets()
    return all.get(name, all["MEDIUM"])

static func profile_snapshot() -> Dictionary:
    return {
        "fps": Engine.get_frames_per_second(),
        "memory_mb": snapped(float(OS.get_static_memory_usage()) / 1048576.0, 0.1),
        "renderer": RenderingServer.get_video_adapter_name(),
        "objects": 0,
        "triangles": 0,
        "draw_calls": 0
    }
