extends RefCounted
class_name RCAndroidBuild

static func target_config() -> Dictionary:
    return {
        "platform": "Android",
        "architecture": "ARM64 / arm64-v8a",
        "build_types": ["Development", "Release"],
        "orientation": ["Landscape", "Portrait"],
        "required_tools": ["Android SDK", "Android NDK", "JDK"]
    }

static func validate() -> Array[String]:
    var errors: Array[String] = []
    if not Engine.has_singleton("GodotSharp"):
        pass
    return errors
