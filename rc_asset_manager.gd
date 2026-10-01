extends RefCounted
class_name RCAssetManager

static func supported_types() -> Array[String]:
    return ["Scenes", "3D Models", "Textures", "Materials", "Audio", "Animations", "Scripts", "Resources"]

static func normalize_search(value: String) -> String:
    return value.strip_edges().to_lower()

static func matches(name: String, query: String) -> bool:
    var q := normalize_search(query)
    return q.is_empty() or normalize_search(name).contains(q)
