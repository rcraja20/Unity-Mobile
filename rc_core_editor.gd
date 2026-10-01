extends RefCounted
class_name RCCoreEditor

static func default_components() -> Array:
    return [
        {"name":"Transform","enabled":true,"type":"Core"},
        {"name":"MeshInstance3D","enabled":true,"type":"Rendering"},
        {"name":"CollisionShape3D","enabled":false,"type":"Physics"},
        {"name":"RigidBody3D","enabled":false,"type":"Physics"},
        {"name":"AudioStreamPlayer3D","enabled":false,"type":"Audio"},
        {"name":"AnimationPlayer","enabled":false,"type":"Animation"},
    ]

static func default_assets() -> Array:
    return [
        {"name":"Main","type":"Scene","path":"res://Main.tscn"},
        {"name":"PlayerMaterial","type":"Material","path":"res://materials/PlayerMaterial.tres"},
        {"name":"PlayerController","type":"Script","path":"res://scripts/PlayerController.gd"},
        {"name":"MainAnimation","type":"Animation","path":"res://animations/MainAnimation.tres"},
        {"name":"Theme","type":"UI Theme","path":"res://ui/Theme.tres"},
    ]

static func default_materials() -> Array:
    return [
        {"name":"PlayerMaterial","albedo":"#4c7dff","roughness":"0.65","metallic":"0.0"},
        {"name":"EnvironmentMaterial","albedo":"#687384","roughness":"0.9","metallic":"0.0"},
    ]

static func default_animations() -> Array:
    return [
        {"name":"Idle","length":"1.0s","loop":true},
        {"name":"Walk","length":"0.8s","loop":true},
        {"name":"Run","length":"0.55s","loop":true},
    ]

static func default_audio() -> Array:
    return [
        {"name":"Music","bus":"Music","volume":"-6 dB","loop":true},
        {"name":"SFX","bus":"SFX","volume":"-3 dB","loop":false},
    ]
