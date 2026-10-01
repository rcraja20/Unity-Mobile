class_name RCAndroidBuild
extends RefCounted

func target_config() -> Dictionary:
    return {
        "platform": "Android",
        "architecture": "ARM64",
        "abi": "arm64-v8a",
        "build_modes": ["Development", "Release"],
        "orientations": ["Landscape", "Portrait"],
        "required_tools": ["Android SDK", "Android NDK", "JDK 17", "Gradle"]
    }

func validate() -> Array[String]:
    var errors: Array[String] = []
    var sdk := OS.get_environment("ANDROID_HOME")
    if sdk.is_empty():
        sdk = OS.get_environment("ANDROID_SDK_ROOT")
    if sdk.is_empty():
        errors.append("Android SDK path is not configured (ANDROID_HOME/ANDROID_SDK_ROOT).")
    if OS.get_environment("JAVA_HOME").is_empty():
        errors.append("JAVA_HOME is not configured; JDK 17 is required for the documented Android build workflow.")
    return errors

func validation_summary() -> String:
    var errors := validate()
    if errors.is_empty():
        return "Android ARM64 build environment variables look configured."
    return "Build setup needs attention:\n- " + "\n- ".join(errors)
