extends Control

var projects: Array[String] = []
var current_project := ""
var selected_object := ""
var object_data: Dictionary = {}
var component_data: Dictionary = {}
var asset_data: Array = []
var material_data: Array = []
var animation_data: Array = []
var audio_data: Array = []
var script_text := "# PlayerController.gd\nextends CharacterBody3D\n\nfunc _physics_process(delta):\n    pass\n"
var quality_preset := "MEDIUM"
var status_label: Label
var content: VBoxContainer
var hierarchy_list: VBoxContainer
var viewport_info: Label
var profiler_label: Label
var build_target_label: Label
var privacy_label: Label
var accessibility_label: Label
var console_text: TextEdit
var scene_doc := RCSceneDocument.new()
var diagnostics := RCDiagnostics.new()
var scene_camera: Camera3D
var scene_world: Node3D
var scene_view_container: SubViewportContainer
var orbit_yaw := 35.0
var orbit_pitch := -22.0
var orbit_distance := 8.0
var touch_active := false
var last_pointer := Vector2.ZERO

func _ready() -> void:
    RCProjectStore.ensure_root()
    for c in RCCoreEditor.default_components():
        component_data[c.name] = c
    asset_data = RCCoreEditor.default_assets()
    material_data = RCCoreEditor.default_materials()
    animation_data = RCCoreEditor.default_animations()
    audio_data = RCCoreEditor.default_audio()
    diagnostics.message_added.connect(_on_diagnostic)
    _refresh_project_names()
    _build_ui()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("111318")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 0)
    add_child(root)

    var top := HBoxContainer.new()
    top.custom_minimum_size.y = 72
    top.add_theme_constant_override("separation", 10)
    root.add_child(top)

    var brand := Label.new()
    brand.text = "  RC MOBILE STUDIO"
    brand.add_theme_font_size_override("font_size", 25)
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(brand)

    for data in [["＋ New Project", 170, "_new_project"], ["Save", 100, "_save_current"], ["▶ Play", 110, "_play_test"]]:
        var b := Button.new()
        b.text = data[0]
        b.custom_minimum_size = Vector2(data[1], 56)
        b.pressed.connect(Callable(self, data[2]))
        top.add_child(b)

    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(body)

    var sidebar := VBoxContainer.new()
    sidebar.custom_minimum_size.x = 235
    sidebar.add_theme_constant_override("separation", 6)
    body.add_child(sidebar)
    for label in ["Projects","Scene","Hierarchy","Inspector","Assets","Asset Manager","Scripts","Console","Profiler","Build","Privacy","Accessibility","Game Controls"]:
        var b := Button.new()
        b.text = label
        b.custom_minimum_size.y = 48
        b.pressed.connect(_show_panel.bind(label))
        sidebar.add_child(b)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 8)
    body.add_child(content)

    status_label = Label.new()
    status_label.text = "Ready — create a local project"
    status_label.custom_minimum_size.y = 34
    root.add_child(status_label)
    _show_panel("Projects")

func _clear_content() -> void:
    for child in content.get_children():
        child.queue_free()

func _show_panel(name: String) -> void:
    _clear_content()
    var title := Label.new()
    title.text = name
    title.add_theme_font_size_override("font_size", 27)
    content.add_child(title)
    match name:
        "Projects": _projects_panel()
        "Scene": _scene_panel()
        "Hierarchy": _hierarchy_panel()
        "Inspector": _inspector_panel()
        "Assets": _assets_panel()
        "Asset Manager": _asset_manager_panel()
        "Scripts": _scripts_panel()
        "Console": _console_panel()
        "Profiler": _profiler_panel()
        "Build": _build_panel()
        "Privacy": _privacy_panel()
        "Accessibility": _accessibility_panel()
        "Game Controls": _game_controls_panel()

func _projects_panel() -> void:
    var info := Label.new()
    info.text = "Local project workspace — stored in the app sandbox."
    content.add_child(info)
    var list := VBoxContainer.new()
    content.add_child(list)
    for p in projects:
        var b := Button.new()
        b.text = p + ("  ✓" if p == current_project else "")
        b.custom_minimum_size.y = 50
        b.pressed.connect(_open_local_project.bind(p))
        list.add_child(b)
    if projects.is_empty():
        var empty := Label.new()
        empty.text = "No projects yet. Tap New Project."
        list.add_child(empty)

func _scene_panel() -> void:
    var help := Label.new()
    help.text = "3D Scene workspace — select an object, then use Inspector."
    content.add_child(help)
    var viewport := ColorRect.new()
    viewport.color = Color("1b2028")
    viewport.custom_minimum_size.y = 300
    viewport.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(viewport)
    viewport_info = Label.new()
    viewport_info.text = "3D VIEWPORT\n\nSelected: " + (selected_object if selected_object else "None")
    viewport_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    viewport_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    viewport.set_clip_contents(true)
    viewport.add_child(viewport_info)
    var actions := HBoxContainer.new()
    content.add_child(actions)
    for action in ["Focus","Move","Rotate","Scale","Delete"]:
        var b := Button.new()
        b.text = action
        b.custom_minimum_size = Vector2(115, 48)
        b.pressed.connect(_scene_action.bind(action))
        actions.add_child(b)

func _build_3d_viewport() -> Control:
    var holder := Control.new()
    holder.custom_minimum_size = Vector2(600, 360)
    scene_view_container = SubViewportContainer.new()
    scene_view_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scene_view_container.stretch = true
    scene_view_container.mouse_filter = Control.MOUSE_FILTER_PASS
    holder.add_child(scene_view_container)

    var sub := SubViewport.new()
    sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    sub.transparent_bg = false
    sub.world_3d = World3D.new()
    scene_view_container.add_child(sub)

    scene_world = Node3D.new()
    sub.add_child(scene_world)

    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("171b22")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("aab4c4")
    environment.ambient_light_energy = 0.55
    env.environment = environment
    scene_world.add_child(env)

    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-50, -35, 0)
    light.light_energy = 1.4
    scene_world.add_child(light)

    scene_camera = Camera3D.new()
    scene_camera.current = true
    scene_world.add_child(scene_camera)

    var floor := MeshInstance3D.new()
    var floor_mesh := PlaneMesh.new()
    floor_mesh.size = Vector2(20, 20)
    floor.mesh = floor_mesh
    floor.position.y = -0.02
    scene_world.add_child(floor)

    for object_name in object_data.keys():
        var item: Dictionary = object_data[object_name]
        var kind := str(item.get("kind", "Node3D"))
        if kind.contains("Camera") or kind.contains("Light"):
            continue
        var visual := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = Vector3(1, 1, 1)
        visual.mesh = box
        visual.name = str(object_name)
        visual.position = _parse_vec3(str(item.get("position", "0, 0, 0")), Vector3.ZERO)
        visual.rotation_degrees = _parse_vec3(str(item.get("rotation", "0, 0, 0")), Vector3.ZERO)
        visual.scale = _parse_vec3(str(item.get("scale", "1, 1, 1")), Vector3.ONE)
        if str(object_name) == selected_object:
            var selected_mat := StandardMaterial3D.new()
            selected_mat.albedo_color = Color("e8b85a")
            visual.material_override = selected_mat
        scene_world.add_child(visual)

    _update_scene_camera()
    return holder

func _update_scene_camera() -> void:
    if scene_camera == null: return
    var target := Vector3.ZERO
    if not selected_object.is_empty() and object_data.has(selected_object):
        target = _parse_vec3(str(object_data[selected_object].get("position", "0, 0, 0")), Vector3.ZERO)
    var yaw := deg_to_rad(orbit_yaw)
    var pitch := deg_to_rad(orbit_pitch)
    var offset := Vector3(
        sin(yaw) * cos(pitch),
        sin(pitch),
        cos(yaw) * cos(pitch)
    ) * orbit_distance
    scene_camera.position = target + offset
    scene_camera.look_at(target, Vector3.UP)

func _refresh_viewport_objects() -> void:
    if not scene_world:
        return
    for child in scene_world.get_children():
        if child is MeshInstance3D and child.name.begins_with("RCObject_"):
            child.queue_free()
    for name in object_data.keys():
        var data: Dictionary = object_data[name]
        if str(data.get("type", "")) in ["Camera3D", "DirectionalLight3D", "Light3D"]:
            continue
        var mesh := MeshInstance3D.new()
        mesh.name = "RCObject_" + str(name)
        var box := BoxMesh.new()
        box.size = Vector3.ONE
        mesh.mesh = box
        var material := StandardMaterial3D.new()
        if str(name) == selected_object:
            material.albedo_color = Color(1.0, 0.75, 0.15)
            material.emission_enabled = true
            material.emission = Color(0.18, 0.12, 0.02)
        else:
            material.albedo_color = Color(0.35, 0.45, 0.55)
        mesh.material_override = material
        mesh.position = _parse_vec3(str(data.get("position", "0,0,0")), Vector3.ZERO)
        mesh.rotation_degrees = _parse_vec3(str(data.get("rotation", "0,0,0")), Vector3.ZERO)
        mesh.scale = _parse_vec3(str(data.get("scale", "1,1,1")), Vector3.ONE)
        scene_world.add_child(mesh)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        touch_active = event.pressed
        if event.pressed: last_pointer = event.position
    elif event is InputEventScreenDrag and touch_active:
        var delta := event.position - last_pointer
        last_pointer = event.position
        orbit_yaw -= delta.x * 0.35
        orbit_pitch = clamp(orbit_pitch - delta.y * 0.25, -80.0, 80.0)
        _update_scene_camera()
    elif event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            orbit_distance = max(2.0, orbit_distance - 0.6)
            _update_scene_camera()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            orbit_distance = min(40.0, orbit_distance + 0.6)
            _update_scene_camera()
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        orbit_yaw -= event.relative.x * 0.35
        orbit_pitch = clamp(orbit_pitch - event.relative.y * 0.25, -80.0, 80.0)
        _update_scene_camera()

func _hierarchy_panel() -> void:
    hierarchy_list = VBoxContainer.new()
    hierarchy_list.add_theme_constant_override("separation", 5)
    content.add_child(hierarchy_list)
    _refresh_hierarchy()

func _refresh_hierarchy() -> void:
    if hierarchy_list == null: return
    for child in hierarchy_list.get_children(): child.queue_free()
    for item in object_data.keys():
        var b := Button.new()
        b.text = ("● " if item == selected_object else "○ ") + str(item)
        b.alignment = HORIZONTAL_ALIGNMENT_LEFT
        b.custom_minimum_size.y = 48
        b.pressed.connect(_select_object.bind(str(item)))
        hierarchy_list.add_child(b)
    var row := HBoxContainer.new()
    content.add_child(row)
    for kind in ["Node3D","Camera3D","Light3D","Mesh3D","Audio3D"]:
        var b := Button.new()
        b.text = "+ " + kind
        b.custom_minimum_size.y = 48
        b.pressed.connect(_add_object.bind(kind))
        row.add_child(b)

func _select_object(name: String) -> void:
    selected_object = name
    status_label.text = "Selected: " + name
    _refresh_viewport_objects()
    _show_panel("Inspector")

func _add_object(kind: String) -> void:
    var name := kind + "_" + str(object_data.size() + 1)
    object_data[name] = {"kind":kind,"position":"0, 0, 0","rotation":"0, 0, 0","scale":"1, 1, 1"}
    scene_doc.create_object(name, kind)
    selected_object = name
    diagnostics.log_info("Created " + kind + ": " + name)
    _show_panel("Hierarchy")

func _inspector_panel() -> void:
    if selected_object.is_empty() or not object_data.has(selected_object):
        content.add_child(Label.new())
        content.get_child(content.get_child_count()-1).text = "Nothing selected. Open Hierarchy."
        return
    var heading := Label.new()
    heading.text = "Selected: " + selected_object
    heading.add_theme_font_size_override("font_size", 21)
    content.add_child(heading)
    for key in ["position","rotation","scale"]:
        var row := HBoxContainer.new()
        var label := Label.new()
        label.text = key.capitalize()
        label.custom_minimum_size.x = 100
        row.add_child(label)
        var edit := LineEdit.new()
        edit.text = str(object_data[selected_object].get(key, ""))
        edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        edit.custom_minimum_size.y = 48
        edit.text_submitted.connect(_set_transform.bind(key, edit))
        row.add_child(edit)
        content.add_child(row)
    var apply := Button.new()
    apply.text = "Apply Transform"
    apply.custom_minimum_size.y = 50
    apply.pressed.connect(func(): _save_current(); _show_panel("Scene"))
    content.add_child(apply)
    var duplicate := Button.new()
    duplicate.text = "Duplicate Object"
    duplicate.custom_minimum_size.y = 50
    duplicate.pressed.connect(_duplicate_selected)
    content.add_child(duplicate)
    var parent := Button.new()
    parent.text = "Parent To First Object"
    parent.custom_minimum_size.y = 50
    parent.pressed.connect(_parent_selected)
    content.add_child(parent)
    var comp_title := Label.new()
    comp_title.text = "Components"
    comp_title.add_theme_font_size_override("font_size", 20)
    content.add_child(comp_title)
    var object_components: Array = object_data[selected_object].get("components", [])
    for component_name in component_data.keys():
        var toggle := CheckButton.new()
        toggle.text = str(component_name)
        toggle.button_pressed = str(component_name) in object_components
        toggle.custom_minimum_size.y = 44
        toggle.toggled.connect(_toggle_component.bind(component_name))
        content.add_child(toggle)
    var add := Button.new()
    add.text = "+ Add Component"
    add.custom_minimum_size.y = 50
    add.pressed.connect(_add_component)
    content.add_child(add)

func _set_transform(key: String, edit: LineEdit) -> void:
    if selected_object.is_empty(): return
    object_data[selected_object][key] = edit.text
    var id := scene_doc.find_by_name(selected_object)
    if id != "":
        var parsed := _parse_vec3(edit.text, Vector3.ZERO if key != "scale" else Vector3.ONE)
        var obj: Dictionary = scene_doc.objects[id]
        var pos: Vector3 = obj.get("position", Vector3.ZERO)
        var rot: Vector3 = obj.get("rotation", Vector3.ZERO)
        var scl: Vector3 = obj.get("scale", Vector3.ONE)
        if key == "position": pos = parsed
        elif key == "rotation": rot = parsed
        else: scl = parsed
        scene_doc.set_transform(id, pos, rot, scl)
    _save_current()
    diagnostics.log_info(key.capitalize() + " updated for " + selected_object)
    status_label.text = key.capitalize() + " updated"

func _duplicate_selected() -> void:
    if selected_object.is_empty() or not object_data.has(selected_object): return
    var source: Dictionary = object_data[selected_object].duplicate(true)
    var new_name := selected_object + "_Copy"
    var n := 2
    while object_data.has(new_name):
        new_name = selected_object + "_Copy" + str(n)
        n += 1
    object_data[new_name] = source
    scene_doc.duplicate_object(scene_doc.find_by_name(selected_object), new_name)
    selected_object = new_name
    _save_current()
    diagnostics.log_info("Duplicated " + new_name)
    _show_panel("Hierarchy")

func _parent_selected() -> void:
    if selected_object.is_empty(): return
    var parent_name := ""
    for name in object_data.keys():
        if str(name) != selected_object:
            parent_name = str(name)
            break
    if parent_name.is_empty(): return
    object_data[selected_object]["parent"] = parent_name
    scene_doc.set_parent(scene_doc.find_by_name(selected_object), scene_doc.find_by_name(parent_name))
    _save_current()
    diagnostics.log_info("Parenting: " + selected_object + " -> " + parent_name)
    _show_panel("Hierarchy")

func _toggle_component(name: String, enabled: bool) -> void:
    if selected_object.is_empty(): return
    var list: Array = object_data[selected_object].get("components", []).duplicate()
    if enabled and name not in list: list.append(name)
    elif not enabled and name in list: list.erase(name)
    object_data[selected_object]["components"] = list
    diagnostics.log_info(name + (" enabled" if enabled else " disabled") + " on " + selected_object)

func _add_component() -> void:
    var name := "CustomComponent" + str(component_data.size() + 1)
    component_data[name] = {"name":name,"enabled":true,"type":"Custom"}
    _show_panel("Inspector")

func _scene_action(action: String) -> void:
    if selected_object.is_empty(): return
    if action == "Delete":
        object_data.erase(selected_object)
        scene_doc.delete_object(selected_object)
        selected_object = ""
        _save_current()
        _show_panel("Hierarchy")
        return
    if action == "Focus":
        viewport_info.text = "3D VIEWPORT\\n\\nFocused: " + selected_object
    elif action == "Move":
        object_data[selected_object]["position"] = "0, 0, 0"
    elif action == "Rotate":
        object_data[selected_object]["rotation"] = "0, 0, 0"
    elif action == "Scale":
        object_data[selected_object]["scale"] = "1, 1, 1"
    _save_current()
    status_label.text = action + " action applied to " + selected_object
    if viewport_info: viewport_info.text = "3D VIEWPORT\n\nSelected: " + selected_object + "\nLast action: " + action

func _asset_import_action() -> void:
    var dialog := FileDialog.new()
    dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
    dialog.access = FileDialog.ACCESS_FILESYSTEM
    dialog.filters = PackedStringArray(["*.tscn,*.scn,*.obj,*.glb,*.gltf,*.png,*.jpg,*.jpeg,*.webp,*.wav,*.ogg,*.mp3 ; Supported Assets"])
    dialog.file_selected.connect(_on_asset_file_selected)
    add_child(dialog)
    dialog.popup_centered_ratio(0.85)

func _on_asset_file_selected(path: String) -> void:
    var project_dir := str(project_manager.current_project.get("path", "")) if project_manager.current_project else ""
    if project_dir.is_empty():
        diagnostics.log_warning("Open a project before importing assets.")
        return
    var source := FileAccess.open(path, FileAccess.READ)
    if source == null:
        diagnostics.log_error("Could not read asset: " + path)
        return
    var bytes := source.get_buffer(source.get_length())
    var assets_dir := project_dir.path_join("assets")
    DirAccess.make_dir_recursive_absolute(assets_dir)
    var target := assets_dir.path_join(path.get_file())
    var out := FileAccess.open(target, FileAccess.WRITE)
    if out == null:
        diagnostics.log_error("Could not write imported asset.")
        return
    out.store_buffer(bytes)
    diagnostics.log_info("Imported asset: " + path.get_file())
    _show_panel("Asset Manager")

func _assets_panel() -> void:
    for tab in ["Assets","Materials","Animation","Audio"]:
        var b := Button.new()
        b.text = tab
        b.custom_minimum_size.y = 44
        b.pressed.connect(_asset_tab.bind(tab))
        content.add_child(b)
    var source: Array = asset_data
    if tab_source() == "Materials": source = material_data
    elif tab_source() == "Animation": source = animation_data
    elif tab_source() == "Audio": source = audio_data
    for item in source:
        var row := Label.new()
        row.text = "• " + str(item.get("name","")) + "  [" + tab_source() + "]"
        row.custom_minimum_size.y = 34
        content.add_child(row)
    var import_btn := Button.new()
    import_btn.text = "+ Import Asset"
    import_btn.custom_minimum_size.y = 50
    import_btn.pressed.connect(func(): diagnostics.log_info("Asset import requested"))
    content.add_child(import_btn)

var asset_tab_name := "Assets"
func tab_source() -> String: return asset_tab_name
func _asset_tab(tab: String) -> void:
    asset_tab_name = tab
    _show_panel("Assets")

func _asset_manager_panel() -> void:
    var search := LineEdit.new()
    search.placeholder_text = "Search assets..."
    search.custom_minimum_size.y = 50
    content.add_child(search)
    var type := OptionButton.new()
    for t in RCAssetManager.supported_types(): type.add_item(t)
    content.add_child(type)
    var list := ItemList.new()
    list.size_flags_vertical = Control.SIZE_EXPAND_FILL
    for item in asset_data + material_data + animation_data + audio_data:
        list.add_item(str(item.get("name","")))
    content.add_child(list)
    var row := HBoxContainer.new()
    content.add_child(row)
    for label in ["Import","Create Folder","Refresh"]:
        var b := Button.new()
        b.text = label
        b.custom_minimum_size = Vector2(150, 50)
        b.pressed.connect(func(): diagnostics.log_info(label + " asset action requested"))
        row.add_child(b)

func _save_script_to_project() -> void:
    if not project_manager.current_project:
        diagnostics.log_warning("Open a project before saving scripts.")
        return
    var project_dir := str(project_manager.current_project.get("path", ""))
    if project_dir.is_empty(): return
    var scripts_dir := project_dir.path_join("scripts")
    DirAccess.make_dir_recursive_absolute(scripts_dir)
    var target := scripts_dir.path_join("Main.gd")
    var file := FileAccess.open(target, FileAccess.WRITE)
    if file:
        file.store_string(script_text)
        diagnostics.log_info("Saved script: scripts/Main.gd")
        status_label.text = "Script saved"

func _scripts_panel() -> void:
    var edit := TextEdit.new()
    edit.text = script_text
    edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(edit)
    var save := Button.new()
    save.text = "Save Script"
    save.custom_minimum_size.y = 50
    save.pressed.connect(func(): script_text = edit.text; diagnostics.log_info("Script saved in editor session."))
    content.add_child(save)

func _console_panel() -> void:
    console_text = TextEdit.new()
    console_text.editable = false
    console_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
    console_text.text = _diagnostic_text()
    content.add_child(console_text)

func _on_diagnostic(level: String, message: String) -> void:
    if console_text: console_text.text = _diagnostic_text()
func _diagnostic_text() -> String:
    var out := "RC Mobile Studio Console\n"
    for e in diagnostics.entries:
        out += "[%s] %s %s\n" % [e.time,e.level,e.message]
    return out

func _profiler_panel() -> void:
    var row := HBoxContainer.new()
    content.add_child(row)
    for preset in ["LOW","MEDIUM","HIGH","ULTRA"]:
        var b := Button.new()
        b.text = preset
        b.custom_minimum_size = Vector2(110, 48)
        b.pressed.connect(_set_quality_preset.bind(preset))
        row.add_child(b)
    profiler_label = Label.new()
    profiler_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(profiler_label)
    _refresh_profiler()
    var refresh := Button.new()
    refresh.text = "Refresh Metrics"
    refresh.custom_minimum_size.y = 50
    refresh.pressed.connect(_refresh_profiler)
    content.add_child(refresh)

func _set_quality_preset(preset: String) -> void:
    quality_preset = preset
    var settings := RCMobileOptimizer.apply_preset(preset)
    Engine.max_fps = int(settings["fps"])
    status_label.text = "Quality preset: " + preset
    _refresh_profiler()
func _refresh_profiler() -> void:
    if profiler_label == null: return
    var p := RCMobileOptimizer.profile_snapshot()
    profiler_label.text = "Preset: %s\nFPS: %s\nMemory: %s MB\nRenderer: %s\nScene objects: %s" % [quality_preset,p.fps,p.memory_mb,p.renderer,object_data.size()]

func _export_project_package() -> void:
    if not project_manager.current_project:
        diagnostics.log_warning("Open a project before exporting.")
        return
    var project_dir := str(project_manager.current_project.get("path", ""))
    if project_dir.is_empty(): return
    var export_dir := project_dir.path_join("exports")
    DirAccess.make_dir_recursive_absolute(export_dir)
    var report := {
        "project": project_manager.current_project,
        "scene": scene_doc.to_dict(),
        "android_target": "arm64-v8a",
        "renderer": "Godot Android",
        "generated_by": "RC Mobile Studio"
    }
    var file := FileAccess.open(export_dir.path_join("android_build_config.json"), FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(report, "\t"))
        diagnostics.log_info("Android build configuration exported.")
        status_label.text = "Android build configuration ready"

func _build_panel() -> void:
    build_target_label = Label.new()
    build_target_label.text = "Target: Android ARM64 (arm64-v8a)\nDevelopment / Release"
    content.add_child(build_target_label)
    for placeholder in ["Application name","Package name (e.g. com.rcempire.game)","Version (e.g. 1.0.0)"]:
        var e := LineEdit.new()
        e.placeholder_text = placeholder
        e.custom_minimum_size.y = 50
        content.add_child(e)
    for kind in ["Development","Release"]:
        var b := Button.new()
        b.text = kind
        b.custom_minimum_size.y = 50
        b.pressed.connect(func(): build_target_label.text = "Android ARM64\nSelected build: " + kind)
        content.add_child(b)
    var validate := Button.new()
    validate.text = "Validate Android Build Setup"
    validate.custom_minimum_size.y = 52
    validate.pressed.connect(func():
        var errors := RCAndroidBuild.validate()
        build_target_label.text = "Android configuration ready." if errors.is_empty() else str(errors)
    )
    content.add_child(validate)
    var build := Button.new()
    build.text = "Build Android ARM64"
    build.custom_minimum_size.y = 58
    build.pressed.connect(func(): diagnostics.log_info("Android ARM64 build requested; CI workflow handles the actual editor build."))
    content.add_child(build)

func _privacy_panel() -> void:
    privacy_label = Label.new()
    privacy_label.text = "Offline-first enabled.\nNo silent project upload.\nNo hidden telemetry.\nCredentials are not stored in the client."
    content.add_child(privacy_label)
    var path := LineEdit.new()
    path.text = RCOfflineSecurity.project_root()
    path.editable = false
    path.custom_minimum_size.y = 50
    content.add_child(path)

func _accessibility_panel() -> void:
    accessibility_label = Label.new()
    accessibility_label.text = "Large touch targets: ON\nUI scale: 100%\nHigh contrast: OFF\nReduced motion: OFF"
    content.add_child(accessibility_label)
    var scale := HSlider.new()
    scale.min_value = 0.85
    scale.max_value = 1.50
    scale.step = 0.05
    scale.value = 1.0
    scale.custom_minimum_size.y = 55
    content.add_child(scale)
    var contrast := CheckButton.new()
    contrast.text = "High Contrast"
    contrast.toggled.connect(func(v): accessibility_label.text = "Large touch targets: ON\nUI scale: %d%%\nHigh contrast: %s\nReduced motion: OFF" % [int(scale.value*100.0),str(v)])
    content.add_child(contrast)
    var reduced := CheckButton.new()
    reduced.text = "Reduced Motion"
    content.add_child(reduced)

func _game_control_press(action: String, pressed: bool) -> void:
    if game_controls:
        match action:
            "forward": game_controls.set_move(Vector2(0, -1) if pressed else Vector2.ZERO)
            "back": game_controls.set_move(Vector2(0, 1) if pressed else Vector2.ZERO)
            "left": game_controls.set_move(Vector2(-1, 0) if pressed else Vector2.ZERO)
            "right": game_controls.set_move(Vector2(1, 0) if pressed else Vector2.ZERO)
            "sprint": game_controls.set_sprint(pressed)
            "look_left": game_controls.set_look(Vector2(-1, 0) if pressed else Vector2.ZERO)
            "look_right": game_controls.set_look(Vector2(1, 0) if pressed else Vector2.ZERO)

func _game_controls_panel() -> void:
    var info := Label.new()
    info.text = "Mobile game controls foundation\nVirtual joystick / look / sprint signals are available to gameplay code."
    content.add_child(info)
    for label in ["Move Joystick","Look Area","Sprint","Jump","Action"]:
        var b := Button.new()
        b.text = label
        b.custom_minimum_size.y = 55
        content.add_child(b)

func _new_project() -> void:
    var dialog := AcceptDialog.new()
    dialog.title = "New Project"
    dialog.dialog_text = "Enter a project name:"
    var input := LineEdit.new()
    input.placeholder_text = "MyGame"
    dialog.add_child(input)
    add_child(dialog)
    dialog.popup_centered(Vector2(500,220))
    dialog.confirmed.connect(func():
        var name := input.text.strip_edges()
        if name.is_empty(): name = "MyGame"
        RCProjectStore.create_project(name)
        if not projects.has(name): projects.append(name)
        current_project = name
        object_data = {"Camera3D":{"kind":"Camera3D","position":"0, 2, 6","rotation":"0, 0, 0","scale":"1, 1, 1"},"DirectionalLight3D":{"kind":"Light3D","position":"0, 4, 0","rotation":"-45, -30, 0","scale":"1, 1, 1"},"Player":{"kind":"Node3D","position":"0, 0, 0","rotation":"0, 0, 0","scale":"1, 1, 1"}}
        _save_current()
        status_label.text = "Created project: " + name
        _show_panel("Projects")
        dialog.queue_free()
    )

func _open_local_project(name: String) -> void:
    current_project = name
    var data := RCProjectStore.load_scene(name)
    if data.has("transforms"):
        object_data = data["transforms"]
        _rebuild_scene_document()
    status_label.text = "Opened: " + name
    diagnostics.log_info("Opened project: " + name)
    _show_panel("Hierarchy")

func _save_current() -> void:
    if current_project.is_empty():
        status_label.text = "Create a project first."
        return
    var data := {"project":current_project,"transforms":object_data,"scene_version":2}
    if RCProjectStore.save_scene(current_project,data) and RCProjectManager.save_scene_file(current_project, data):
        diagnostics.log_info("Saved project: " + current_project)
        status_label.text = "Saved: " + current_project
    else:
        diagnostics.log_error("Save failed")

func _refresh_project_names() -> void:
    projects = RCProjectManager.list_projects()

func _rebuild_scene_document() -> void:
    scene_doc = RCSceneDocument.new()
    selected_object = ""
    for key in object_data.keys():
        var item: Dictionary = object_data[key]
        var kind := str(item.get("kind", "Node3D"))
        var id := scene_doc.create_object(str(key), kind)
        var pos := _parse_vec3(str(item.get("position", "0, 0, 0")), Vector3.ZERO)
        var rot := _parse_vec3(str(item.get("rotation", "0, 0, 0")), Vector3.ZERO)
        var scl := _parse_vec3(str(item.get("scale", "1, 1, 1")), Vector3.ONE)
        scene_doc.set_transform(id, pos, rot, scl)

func _parse_vec3(value: String, fallback: Vector3) -> Vector3:
    var parts := value.split(",")
    if parts.size() != 3: return fallback
    return Vector3(float(parts[0].strip_edges()), float(parts[1].strip_edges()), float(parts[2].strip_edges()))

func _validate_current_scene() -> bool:
    var errors := scene_doc.validate()
    if errors.is_empty():
        diagnostics.log_info("Scene validation passed.")
        return true
    for error in errors:
        diagnostics.log_error(str(error))
    status_label.text = "Scene validation failed: " + str(errors.size()) + " issue(s)"
    return false

func _run_game_test() -> void:
    if not _validate_current_scene():
        return
    var test_scene := Node3D.new()
    test_scene.name = "RCPlayTest"
    var camera := Camera3D.new()
    camera.position = Vector3(0, 3, 8)
    camera.look_at(Vector3.ZERO)
    test_scene.add_child(camera)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-55, -25, 0)
    test_scene.add_child(light)
    for name in object_data.keys():
        var data: Dictionary = object_data[name]
        var mesh := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = Vector3.ONE
        mesh.mesh = box
        mesh.position = _parse_vec3(str(data.get("position", "0,0,0")), Vector3.ZERO)
        mesh.rotation_degrees = _parse_vec3(str(data.get("rotation", "0,0,0")), Vector3.ZERO)
        mesh.scale = _parse_vec3(str(data.get("scale", "1,1,1")), Vector3.ONE)
        test_scene.add_child(mesh)
    add_child(test_scene)
    status_label.text = "Play Test running"
    diagnostics.log_info("Play Test scene launched")
    await get_tree().create_timer(3.0).timeout
    if is_instance_valid(test_scene):
        test_scene.queue_free()
    status_label.text = "Play Test finished"
    diagnostics.log_info("Play Test finished")

func _play_test() -> void:
    if current_project.is_empty():
        status_label.text = "Create or open a project before Play."
        return
    if not _validate_current_scene(): return
    diagnostics.log_info("Play/Test requested for " + current_project)
    status_label.text = "Play/Test ready — scene validation passed"
    _show_panel("Scene")
