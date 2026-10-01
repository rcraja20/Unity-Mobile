extends RefCounted
class_name RCOfflineSecurity

static func policy() -> Dictionary:
    return {
        "offline_first": true,
        "local_project_storage": true,
        "silent_upload": false,
        "hidden_telemetry": false,
        "credentials_in_client": false
    }

static func project_root() -> String:
    return "user://rc_mobile_studio/projects"
