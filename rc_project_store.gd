extends RefCounted
class_name RCProjectStore

const ROOT := "user://rc_mobile_studio/projects"

static func ensure_root() -> void:
    DirAccess.make_dir_recursive_absolute(ROOT)

static func create_project(project_name: String) -> String:
    ensure_root()
    var safe := project_name.strip_edges()
    if safe.is_empty():
        safe = "MyProject"
    safe = safe.replace("/", "_").replace("\\", "_")
    var path := ROOT.path_join(safe)
    DirAccess.make_dir_recursive_absolute(path)
    var file := FileAccess.open(path.path_join("project.json"), FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify({
            "name": safe,
            "version": 1,
            "scene": "Main",
            "objects": ["Camera3D", "DirectionalLight3D", "Player", "Environment"]
        }, "\t"))
        file.close()
    return path

static func save_scene(project_name: String, data: Dictionary) -> bool:
    ensure_root()
    if project_name.is_empty():
        return false
    var path := ROOT.path_join(project_name).path_join("scene.json")
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(data, "\t"))
    file.close()
    return true

static func load_scene(project_name: String) -> Dictionary:
    var path := ROOT.path_join(project_name).path_join("scene.json")
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var value = JSON.parse_string(file.get_as_text())
    file.close()
    return value if typeof(value) == TYPE_DICTIONARY else {}
