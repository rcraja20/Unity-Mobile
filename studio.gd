extends Control

var projects: Array[String] = []
var status_label: Label
var content: VBoxContainer

func _ready() -> void:
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
    top.add_theme_constant_override("separation", 18)
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

    var open_btn := Button.new()
    open_btn.text = "Open Project"
    open_btn.custom_minimum_size = Vector2(170, 56)
    open_btn.pressed.connect(_open_project)
    top.add_child(open_btn)

    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(body)

    var sidebar := VBoxContainer.new()
    sidebar.custom_minimum_size.x = 250
    sidebar.add_theme_constant_override("separation", 10)
    body.add_child(sidebar)
    for label in ["Projects", "Scene", "Hierarchy", "Inspector", "Assets", "Scripts", "Console", "Build"]:
        var b := Button.new()
        b.text = label
        b.custom_minimum_size.y = 52
        b.pressed.connect(_show_panel.bind(label))
        sidebar.add_child(b)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 12)
    body.add_child(content)

    status_label = Label.new()
    status_label.text = "Ready — create or open a project"
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
    title.add_theme_font_size_override("font_size", 30)
    content.add_child(title)
    match name:
        "Projects": _projects_panel()
        "Scene": _scene_panel()
        "Hierarchy": _hierarchy_panel()
        "Inspector": _inspector_panel()
        "Assets": _assets_panel()
        "Scripts": _scripts_panel()
        "Console": _console_panel()
        "Build": _build_panel()

func _projects_panel() -> void:
    var info := Label.new()
    info.text = "Local-first project workspace\nProjects are stored on the device; no silent uploads."
    content.add_child(info)
    for p in projects:
        var b := Button.new()
        b.text = p
        b.custom_minimum_size.y = 52
        content.add_child(b)

func _scene_panel() -> void:
    var help := Label.new()
    help.text = "Touch editor foundation\nTap objects to select. Drag to move."
    content.add_child(help)
    var viewport := ColorRect.new()
    viewport.color = Color("1b2028")
    viewport.custom_minimum_size = Vector2(0, 360)
    viewport.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(viewport)
    var center := Label.new()
    center.text = "3D SCENE VIEWPORT\n\nSelect an object from Hierarchy to edit it."
    center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    viewport.add_child(center)

func _hierarchy_panel() -> void:
    for item in ["Main Scene", "  Camera3D", "  DirectionalLight3D", "  Player", "  Environment"]:
        var b := Button.new()
        b.text = item
        b.alignment = HORIZONTAL_ALIGNMENT_LEFT
        b.custom_minimum_size.y = 48
        content.add_child(b)

func _inspector_panel() -> void:
    for item in ["Transform", "Position", "Rotation", "Scale", "Components", "Add Component"]:
        var b := Button.new()
        b.text = item
        b.custom_minimum_size.y = 50
        content.add_child(b)

func _assets_panel() -> void:
    var label := Label.new()
    label.text = "Assets\n\nBrowse imported textures, models, audio, scenes and scripts."
    content.add_child(label)

func _scripts_panel() -> void:
    var edit := TextEdit.new()
    edit.text = "# RC Mobile Studio script workspace\n# Edit project scripts here."
    edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(edit)

func _console_panel() -> void:
    var label := Label.new()
    label.text = "Console\n[INFO] RC Mobile Studio ready."
    content.add_child(label)

func _build_panel() -> void:
    var label := Label.new()
    label.text = "Android Build\n\nTarget: ARM64 / arm64-v8a\nUse the repository Android build workflow for reproducible builds."
    content.add_child(label)

func _new_project() -> void:
    var dialog := AcceptDialog.new()
    dialog.title = "New Project"
    dialog.dialog_text = "Project creation UI is ready for the next editor milestone."
    add_child(dialog)
    dialog.popup_centered(Vector2(500, 220))
    dialog.confirmed.connect(dialog.queue_free)

func _open_project() -> void:
    status_label.text = "Open Project: Android file/project picker integration is the next filesystem milestone."
