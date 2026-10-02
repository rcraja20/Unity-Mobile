extends RefCounted
class_name RCProjectManager

static func root() -> String:
    return "user://rc_mobile_studio/projects"

static func ensure_project(name: String) -> String:
    var dir := root().path_join(name)
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
    return dir

static func project_file(name: String) -> String:
    return ensure_project(name).path_join("project.json")

static func save_metadata(name: String, metadata: Dictionary) -> bool:
    var f := FileAccess.open(project_file(name), FileAccess.WRITE)
    if f == null: return false
    f.store_string(JSON.stringify(metadata, "\\t"))
    f.close()
    return true

static func load_metadata(name: String) -> Dictionary:
    var path := project_file(name)
    if not FileAccess.file_exists(path): return {}
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null: return {}
    var parsed = JSON.parse_string(f.get_as_text())
    f.close()
    return parsed if parsed is Dictionary else {}

static func list_projects() -> Array[String]:
    var result: Array[String] = []
    var d := DirAccess.open(root())
    if d == null: return result
    d.list_dir_begin()
    var n := d.get_next()
    while n != "":
        if d.current_is_dir() and n not in [".", ".."]: result.append(n)
        n = d.get_next()
    d.list_dir_end()
    return result

static func backup(project_path: String) -> String:
    var backup_path := project_path + ".backup.json"
    var scene_path := project_path.path_join("scene.json")
    if not FileAccess.file_exists(scene_path): return ""
    var src := FileAccess.open(scene_path, FileAccess.READ)
    var dst := FileAccess.open(backup_path, FileAccess.WRITE)
    if src == null or dst == null: return ""
    dst.store_string(src.get_as_text())
    return backup_path
