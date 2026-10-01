extends Control

var projects: Array[String] = []
var current_project := ""
var selected_object := ""
var object_data := {
    "Camera3D": {"position": "0, 2, 6", "rotation": "0, 0, 0", "scale": "1, 1, 1"},
    "DirectionalLight3D": {"position": "0, 4, 0", "rotation": "-45, -30, 0", "scale": "1, 1, 1"},
    "Player": {"position": "0, 0, 0", "rotation": "0, 0, 0", "scale": "1, 1, 1"},
    "Environment": {"position": "0, 0, 0", "rotation": "0, 0, 0", "scale": "1, 1, 1"}
}
var status_label: Label
var content: VBoxContainer
var project_list: VBoxContainer
var hierarchy_list: VBoxContainer
var viewport_info: Label
var core_tab := "Assets"
var component_data: Dictionary = {}
var asset_data: Array = []
var material_data: Array = []
var animation_data: Array = []
var audio_data: Array = []
var script_text := "# PlayerController.gd\nextends CharacterBody3D\n\nfunc _physics_process(delta):\n    pass\n"
var quality_preset := "MEDIUM"
var profiler_label: Label

func _ready() -> void:
    RCProjectStore.ensure_root()
    for c in RCCoreEditor.default_components():
        component_data[c.name] = c
    asset_data = RCCoreEditor.default_assets()
    material_data = RCCoreEditor.default_materials()
    animation_data = RCCoreEditor.default_animations()
    audio_data = RCCoreEditor.default_audio()
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
    top.add_theme_constant_override("separation", 12)
    root.add_child(top)

    var brand := Label.new()
    brand.text = "  RC MOBILE STUDIO"
    brand.add_theme_font_size_override("font_size", 25)
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(brand)

    var new_btn := Button.new()
    new_btn.text = "＋ New Project"
    new_btn.custom_minimum_size = Vector2(190, 56)
    new_btn.pressed.connect(_new_project)
    top.add_child(new_btn)

    var save_btn := Button.new()
    save_btn.text = "Save"
    save_btn.custom_minimum_size = Vector2(110, 56)
    save_btn.pressed.connect(_save_current)
    top.add_child(save_btn)

    var play_btn := Button.new()
    play_btn.text = "▶ Play"
    play_btn.custom_minimum_size = Vector2(120, 56)
    play_btn.pressed.connect(_play_test)
    top.add_child(play_btn)

    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(body)

    var sidebar := VBoxContainer.new()
    sidebar.custom_minimum_size.x = 250
    sidebar.add_theme_constant_override("separation", 8)
    body.add_child(sidebar)
    for label in ["Projects", "Scene", "Hierarchy", "Inspector", "Assets", "Scripts", "Console", "Build"]:
        var b := Button.new()
        b.text = label
        b.custom_minimum_size.y = 50
        b.pressed.connect(_show_panel.bind(label))
        sidebar.add_child(b)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    body.add_child(content)

    status_label = Label.new()
    status_label.text = "Ready — create a local project"
    status_label.custom_minimum_size.y = 36
    status_label.add_theme_color_override("font_color", Color("aeb7c4"))
    root.add_child(status_label)

    _show_panel("Projects")

func _clear_content() -> void:
    for child in content.get_children():
        child.queue_free()

func _show_panel(name: String) -> void:
    _clear_content()
    var title := Label.new()
    title.text = name
    title.add_theme_font_size_override("font_size", 28)
    content.add_child(title)
    match name:
        "Projects": _projects_panel()
        "Scene": _scene_panel()
        "Hierarchy": _hierarchy_panel()
        "Inspector": _inspector_panel()
        "Assets": _assets_panel()
        "Scripts": _scripts_panel()
        "Console": _console_panel()
        "Build": _build_panel(),
        "Profiler": _profiler_panel()

func _projects_panel() -> void:
    var info := Label.new()
    info.text = "Local project workspace\nProjects are stored in the app sandbox."
    content.add_child(info)
    project_list = VBoxContainer.new()
    project_list.add_theme_constant_override("separation", 8)
    content.add_child(project_list)
    _refresh_projects()

func _refresh_projects() -> void:
    if project_list == null:
        return
    for child in project_list.get_children():
        child.queue_free()
    if projects.is_empty():
        var empty := Label.new()
        empty.text = "No projects yet. Tap New Project."
        project_list.add_child(empty)
        return
    for p in projects:
        var b := Button.new()
        b.text = p + ("  ✓" if p == current_project else "")
        b.custom_minimum_size.y = 52
        b.pressed.connect(_open_local_project.bind(p))
        project_list.add_child(b)

func _scene_panel() -> void:
    var help := Label.new()
    help.text = "Scene workspace\nSelect an object from Hierarchy, then edit its Transform in Inspector."
    content.add_child(help)

    var viewport := ColorRect.new()
    viewport.color = Color("1b2028")
    viewport.custom_minimum_size = Vector2(0, 280)
    viewport.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(viewport)

    viewport_info = Label.new()
    viewport_info.text = "3D VIEWPORT\n\nSelected: " + (selected_object if selected_object else "None") + "\n\nTouch viewport foundation is ready for the next camera/gizmo milestone."
    viewport_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    viewport_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    viewport_info.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    viewport.add_child(viewport_info)

    var actions := HBoxContainer.new()
    content.add_child(actions)
    for action in ["Focus", "Move", "Rotate", "Scale"]:
        var b := Button.new()
        b.text = action
        b.custom_minimum_size = Vector2(130, 48)
        b.pressed.connect(_scene_action.bind(action))
        actions.add_child(b)

func _hierarchy_panel() -> void:
    hierarchy_list = VBoxContainer.new()
    hierarchy_list.add_theme_constant_override("separation", 6)
    content.add_child(hierarchy_list)
    _refresh_hierarchy()

func _refresh_hierarchy() -> void:
    if hierarchy_list == null:
        return
    for child in hierarchy_list.get_children():
        child.queue_free()
    for item in object_data.keys():
        var b := Button.new()
        b.text = ("● " if item == selected_object else "○ ") + item
        b.alignment = HORIZONTAL_ALIGNMENT_LEFT
        b.custom_minimum_size.y = 50
        b.pressed.connect(_select_object.bind(item))
        hierarchy_list.add_child(b)

    var add := Button.new()
    add.text = "＋ Add GameObject"
    add.custom_minimum_size.y = 52
    add.pressed.connect(_add_object)
    hierarchy_list.add_child(add)

func _select_object(name: String) -> void:
    selected_object = name
    status_label.text = "Selected: " + name
    _show_panel("Inspector")

func _add_object() -> void:
    var name := "GameObject" + str(object_data.size() + 1)
    object_data[name] = {"position": "0, 0, 0", "rotation": "0, 0, 0", "scale": "1, 1, 1"}
    selected_object = name
    _show_panel("Hierarchy")

func _inspector_panel() -> void:
    if selected_object.is_empty():
        var none := Label.new()
        none.text = "Nothing selected. Open Hierarchy and select a GameObject."
        content.add_child(none)
        return
    var heading := Label.new()
    heading.text = "Selected: " + selected_object
    heading.add_theme_font_size_override("font_size", 22)
    content.add_child(heading)
    for key in ["position", "rotation", "scale"]:
        var row := HBoxContainer.new()
        var label := Label.new()
        label.text = key.capitalize()
        label.custom_minimum_size.x = 110
        row.add_child(label)
        var edit := LineEdit.new()
        edit.text = str(object_data[selected_object][key])
        edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        edit.text_submitted.connect(_set_transform.bind(key, edit))
        row.add_child(edit)
        content.add_child(row)
    var save := Button.new()
    save.text = "Apply Transform"
    save.custom_minimum_size.y = 52
    save.pressed.connect(_show_panel.bind("Scene"))
    content.add_child(save)
    var title := Label.new()
    title.text = "Components"
    title.add_theme_font_size_override("font_size", 20)
    content.add_child(title)
    for component_name in component_data.keys():
        var toggle := CheckButton.new()
        toggle.text = str(component_name)
        toggle.button_pressed = bool(component_data[component_name].get("enabled", false))
        toggle.custom_minimum_size.y = 46
        toggle.toggled.connect(_toggle_component.bind(component_name))
        content.add_child(toggle)
    var add := Button.new()
    add.text = "＋ Add Component"
    add.custom_minimum_size.y = 50
    add.pressed.connect(_add_component)
    content.add_child(add)

func _toggle_component(component_name: String, enabled: bool) -> void:
    component_data[component_name]["enabled"] = enabled
    status_label.text = component_name + (" enabled" if enabled else " disabled")

func _add_component() -> void:
    var name := "CustomComponent" + str(component_data.size() + 1)
    component_data[name] = {"name":name,"enabled":true,"type":"Custom"}
    status_label.text = "Added component: " + name
    _show_panel("Inspector")


func _set_transform(key: String, edit: LineEdit) -> void:
    object_data[selected_object][key] = edit.text
    status_label.text = key.capitalize() + " updated for " + selected_object

func _scene_action(action: String) -> void:
    status_label.text = action + " action requested for " + (selected_object if selected_object else "no selection")
    if viewport_info:
        viewport_info.text = "3D VIEWPORT\n\nSelected: " + (selected_object if selected_object else "None") + "\nLast action: " + action

func _assets_panel() -> void:
    var search := LineEdit.new()
    search.placeholder_text = "Search assets..."
    search.custom_minimum_size.y = 48
    content.add_child(search)
    for tab in ["Assets","Materials","Animation","Audio"]:
        var b := Button.new()
        b.text = tab
        b.custom_minimum_size.y = 44
        b.pressed.connect(_asset_tab.bind(tab))
        content.add_child(b)
    var source: Array = asset_data
    if core_tab == "Materials":
        source = material_data
    elif core_tab == "Animation":
        source = animation_data
    elif core_tab == "Audio":
        source = audio_data
    for item in source:
        var row := Label.new()
        row.text = "• " + str(item.get("name","")) + "  [" + core_tab + "]"
        row.custom_minimum_size.y = 36
        content.add_child(row)
    var import_btn := Button.new()
    import_btn.text = "＋ Import Asset"
    import_btn.custom_minimum_size.y = 50
    import_btn.pressed.connect(_import_asset)
    content.add_child(import_btn)

func _asset_tab(tab: String) -> void:
    core_tab = tab
    _show_panel("Assets")

func _import_asset() -> void:
    status_label.text = "Asset import workflow ready for the Android file picker."

func _scripts_panel() -> void:
    var path := Label.new()
    path.text = "scripts/PlayerController.gd"
    content.add_child(path)
    var edit := TextEdit.new()
    edit.text = script_text
    edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(edit)
    var save := Button.new()
    save.text = "Save Script"
    save.custom_minimum_size.y = 50
    save.pressed.connect(func():
        script_text = edit.text
        status_label.text = "Script saved in editor session."
    )
    content.add_child(save)

func _console_panel() -> void:
    var label := Label.new()
    label.text = "[INFO] RC Mobile Studio ready.\n[INFO] Local project store initialized.\n[INFO] Core components/resources loaded."
    content.add_child(label)

func _scripts_panel() -> void:
    var edit := TextEdit.new()
    edit.text = "# RC Mobile Studio script workspace\n# Script editing surface.\n"
    edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(edit)

func _console_panel() -> void:
    var label := Label.new()
    label.text = "Console\n[INFO] RC Mobile Studio ready.\n[INFO] Local-first project store initialized."
    content.add_child(label)

func _profiler_panel() -> void:
    var title := Label.new()
    title.text = "Mobile Profiler"
    title.add_theme_font_size_override("font_size", 24)
    content.add_child(title)

    var preset_row := HBoxContainer.new()
    content.add_child(preset_row)
    for preset in ["LOW","MEDIUM","HIGH","ULTRA"]:
        var b := Button.new()
        b.text = preset
        b.custom_minimum_size = Vector2(120, 48)
        b.pressed.connect(_set_quality_preset.bind(preset))
        preset_row.add_child(b)

    profiler_label = Label.new()
    profiler_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    profiler_label.text = _profile_text()
    content.add_child(profiler_label)

    var refresh := Button.new()
    refresh.text = "Refresh Metrics"
    refresh.custom_minimum_size.y = 50
    refresh.pressed.connect(func():
        profiler_label.text = _profile_text()
    )
    content.add_child(refresh)

func _set_quality_preset(preset: String) -> void:
    quality_preset = preset
    var settings := RCMobileOptimizer.apply_preset(preset)
    Engine.max_fps = int(settings["fps"])
    status_label.text = "Quality preset: " + preset + " (" + str(settings["fps"]) + " FPS target)"
    if profiler_label:
        profiler_label.text = _profile_text()

func _profile_text() -> String:
    var p := RCMobileOptimizer.profile_snapshot()
    return "Preset: " + quality_preset + "\nFPS: " + str(p["fps"]) + "\nMemory: " + str(p["memory_mb"]) + " MB\nRenderer: " + str(p["renderer"]) + "\nScene objects: " + str(object_data.size()) + "\nLOD: enabled by project optimization profile\nAsset streaming: project-local foundation"

func _build_panel() -> void:
    var label := Label.new()
    label.text = "Android Build\n\nTarget: ARM64 / arm64-v8a\nThe repository workflow builds the Android editor artifact when Actions runs.\n\nA verified APK is only reported after a successful Actions artifact is available."
    content.add_child(label)

func _new_project() -> void:
    var dialog := AcceptDialog.new()
    dialog.title = "New Project"
    dialog.dialog_text = "Enter a project name:"
    var input := LineEdit.new()
    input.placeholder_text = "MyGame"
    dialog.add_child(input)
    add_child(dialog)
    dialog.popup_centered(Vector2(500, 220))
    dialog.confirmed.connect(func():
        var name := input.text.strip_edges()
        if name.is_empty():
            name = "MyGame"
        var path := RCProjectStore.create_project(name)
        if not projects.has(name):
            projects.append(name)
        current_project = name
        _save_current()
        status_label.text = "Created project: " + name + " at " + path
        _show_panel("Projects")
        dialog.queue_free()
    )

func _open_local_project(name: String) -> void:
    current_project = name
    var data := RCProjectStore.load_scene(name)
    if not data.is_empty() and data.has("objects"):
        object_data.clear()
        for obj in data["objects"]:
            object_data[str(obj)] = {"position": "0, 0, 0", "rotation": "0, 0, 0", "scale": "1, 1, 1"}
    status_label.text = "Opened: " + name
    _show_panel("Hierarchy")

func _save_current() -> void:
    if current_project.is_empty():
        status_label.text = "Create a project first."
        return
    var data := {"project": current_project, "objects": object_data.keys(), "transforms": object_data}
    if RCProjectStore.save_scene(current_project, data):
        status_label.text = "Saved: " + current_project
    else:
        status_label.text = "Save failed."

func _refresh_project_names() -> void:
    projects.clear()
    RCProjectStore.ensure_root()
    var dir := DirAccess.open("user://rc_mobile_studio/projects")
    if dir:
        dir.list_dir_begin()
        var item := dir.get_next()
        while item != "":
            if dir.current_is_dir() and not item.begins_with("."):
                projects.append(item)
            item = dir.get_next()
        dir.list_dir_end()

func _play_test() -> void:
    if current_project.is_empty():
        status_label.text = "Create or open a project before Play."
        return
    status_label.text = "Play/Test: local scene test mode requested for " + current_project
    _show_panel("Scene")
