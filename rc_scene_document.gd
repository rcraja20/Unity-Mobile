extends RefCounted
class_name RCSceneDocument

var objects: Array[Dictionary] = []
var selected_id := ""

func create_object(name: String, kind := "Node3D") -> String:
    var id := "%s_%s" % [kind.to_lower(), Time.get_ticks_usec()]
    objects.append({"id": id, "name": name, "kind": kind, "parent": "", "position": Vector3.ZERO, "rotation": Vector3.ZERO, "scale": Vector3.ONE, "components": []})
    selected_id = id
    return id

func delete_object(id: String) -> bool:
    for i in range(objects.size() - 1, -1, -1):
        if objects[i]["id"] == id:
            objects.remove_at(i)
            if selected_id == id: selected_id = ""
            return true
    return false

func validate() -> Array[String]:
    var errors: Array[String] = []
    var ids: Dictionary = {}
    for o in objects:
        var id := str(o.get("id", ""))
        if id.is_empty(): errors.append("Scene object has no ID.")
        elif ids.has(id): errors.append("Duplicate scene object ID: " + id)
        ids[id] = true
        if str(o.get("name", "")).strip_edges().is_empty(): errors.append("Scene object " + id + " has no name.")
    for o in objects:
        var parent := str(o.get("parent", ""))
        if not parent.is_empty() and not ids.has(parent): errors.append("Missing parent " + parent + " for " + str(o.get("id", "")))
    return errors

func find_object(id: String) -> Dictionary:
    for o in objects:
        if o["id"] == id: return o
    return {}

func duplicate_object(id: String) -> String:
    var source := find_object(id)
    if source.is_empty(): return ""
    var copy := source.duplicate(true)
    copy["id"] = "%s_%s" % [str(source["kind"]).to_lower(), Time.get_ticks_usec()]
    copy["name"] = "%s Copy" % str(source["name"])
    objects.append(copy)
    selected_id = copy["id"]
    return copy["id"]

func set_parent(id: String, parent_id: String) -> bool:
    for o in objects:
        if o["id"] == id:
            o["parent"] = parent_id
            return true
    return false

func set_transform(id: String, position: Vector3, rotation: Vector3, scale: Vector3) -> bool:
    for o in objects:
        if o["id"] == id:
            o["position"] = position; o["rotation"] = rotation; o["scale"] = scale
            return true
    return false

func to_dict() -> Dictionary:
    return {"version": 1, "objects": objects, "selected_id": selected_id}

func from_dict(data: Dictionary) -> void:
    objects.clear()
    for o in data.get("objects", []):
        objects.append(o)
    selected_id = str(data.get("selected_id", ""))

func save(path: String) -> Error:
    var f := FileAccess.open(path, FileAccess.WRITE)
    if f == null: return FileAccess.get_open_error()
    f.store_string(JSON.stringify(to_dict(), "\t"))
    return OK

func load(path: String) -> Error:
    if not FileAccess.file_exists(path): return ERR_FILE_NOT_FOUND
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null: return FileAccess.get_open_error()
    var parsed = JSON.parse_string(f.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY: return ERR_PARSE_ERROR
    from_dict(parsed)
    return OK
