extends Node
class_name RCDiagnostics

signal message_added(level: String, message: String)
var entries: Array[Dictionary] = []

func log_info(message: String) -> void: _add("INFO", message)
func log_warning(message: String) -> void: _add("WARNING", message)
func log_error(message: String) -> void: _add("ERROR", message)

func _add(level: String, message: String) -> void:
    var entry := {"time": Time.get_time_string_from_system(), "level": level, "message": message}
    entries.append(entry)
    if entries.size() > 500: entries.pop_front()
    message_added.emit(level, message)

func search(query: String) -> Array[Dictionary]:
    var q := query.to_lower()
    return entries.filter(func(e): return q.is_empty() or str(e["message"]).to_lower().contains(q) or str(e["level"]).to_lower().contains(q))
