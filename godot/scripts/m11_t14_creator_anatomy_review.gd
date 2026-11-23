extends "res://scripts/m11_t13_skinned_character_lab.gd"

## T14 visual creator review. This can NEVER approve an ALCHUL anatomy.
## It renders real T13 weighted Godot 3D meshes in a side-by-side comparison.
const REVIEW_PATH: String = "res://data/m11_t14_anatomy_review.json"
const INK: Color = Color(0.065, 0.105, 0.12, 0.95)
const PAPER: Color = Color(0.92, 0.94, 0.90)
const GOLD: Color = Color(0.93, 0.72, 0.39)
const ACCENT: Color = Color(0.61, 0.85, 0.78)
var review: Dictionary = {}
var footer: Label
var status: Label
var selected_review: String = "both"


func _ready() -> void:
    super._ready()
    var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(REVIEW_PATH))
    if not (payload is Dictionary):
        push_error("T14 missing decision evidence JSON")
        return
    review = payload
    if review.get("status", "") != "DECISION_PENDING_NOT_CANON":
        push_error("T14 cannot load approved anatomy from evidence-only review")
        return
    playing = false
    # T13's own top banner and world-space labels are redundant and partly
    # overlap in a scientific A/B presentation. Retain rigs, hide decoration.
    var original_hud: CanvasLayer = get_node("SkeletalStudyHud")
    original_hud.visible = false
    for model_key in ["H-A","H-B"]:
        var world_label: Label3D = get_node_or_null("T07_" + model_key + "/HypothesisLabel")
        if world_label != null:
            world_label.visible = false
    set_clip("rest")
    sample_pose(0.0)
    set_display_mode("both")
    _build_review_overlay()
    _refresh_review()


func _font(words: String, size: int = 14, tint: Color = PAPER) -> Label:
    var text_node := Label.new()
    text_node.text = words
    text_node.add_theme_font_size_override("font_size", size)
    text_node.add_theme_color_override("font_color", tint)
    text_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return text_node


func _panel(x: float, width: float, heading: String, tint: Color) -> VBoxContainer:
    var card := PanelContainer.new()
    card.position = Vector2(x, 478)
    card.custom_minimum_size = Vector2(width, 205)
    var style := StyleBoxFlat.new()
    style.bg_color = INK
    style.border_color = Color(0.34, 0.53, 0.49, 0.73)
    style.set_border_width_all(1)
    style.set_content_margin_all(13)
    card.add_theme_stylebox_override("panel", style)
    (get_node("T14ReviewLayer") as CanvasLayer).add_child(card)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 7)
    card.add_child(stack)
    stack.add_child(_font(heading, 19, tint))
    return stack


func _build_review_overlay() -> void:
    var layer := CanvasLayer.new()
    layer.name = "T14ReviewLayer"
    add_child(layer)

    var title_panel := PanelContainer.new()
    title_panel.name = "T14ScientificHeader"
    title_panel.position = Vector2(20, 15)
    title_panel.custom_minimum_size = Vector2(1240, 95)
    var banner := StyleBoxFlat.new()
    banner.bg_color = Color(0.065, 0.105, 0.12, 0.94)
    banner.set_content_margin_all(13)
    title_panel.add_theme_stylebox_override("panel", banner)
    layer.add_child(title_panel)
    var title_col := VBoxContainer.new()
    title_col.add_theme_constant_override("separation", 4)
    title_panel.add_child(title_col)
    title_col.add_child(_font("ALCHUL  /  T14  —  CREATOR ANATOMY REVIEW", 23, GOLD))
    title_col.add_child(_font("TWO REAL GODOT SKINNED ENGINEERING HYPOTHESES   •   ZERO APPROVED SPECIES   •   UNMEASURED NORMALIZED UNITS", 13, PAPER))
    title_col.add_child(_font("Scientific comparators ≠ fictional evolved morphology. H-C hybrid remains unbuilt; no present-day descendant is depicted.", 13, ACCENT))

    var naming_left := _font("H-A / LONG TAIL", 16, GOLD)
    naming_left.position = Vector2(420, 268)
    layer.add_child(naming_left)
    var naming_right := _font("H-B / COMPACT TAIL", 16, ACCENT)
    naming_right.position = Vector2(865, 268)
    layer.add_child(naming_right)

    var warning_panel := PanelContainer.new()
    warning_panel.position = Vector2(20, 141)
    warning_panel.custom_minimum_size = Vector2(395, 99)
    var info_style := StyleBoxFlat.new()
    info_style.bg_color = Color(0.065, 0.105, 0.12, 0.89)
    info_style.set_content_margin_all(13)
    warning_panel.add_theme_stylebox_override("panel", info_style)
    layer.add_child(warning_panel)
    var explanation := VBoxContainer.new()
    warning_panel.add_child(explanation)
    explanation.add_child(_font("COMPARATIVE EVIDENCE  /  NONCANONICAL", 16, GOLD))
    explanation.add_child(_font("Fossil comparators and software proxies only.", 12, PAPER))
    explanation.add_child(_font("0 both  |  1 long tail  |  2 compact tail", 12, ACCENT))

    var a: VBoxContainer = _panel(20, 385, "H-A    /    LONG-TAIL CONTINUITY", GOLD)
    a.add_child(_font("T10 fixed 2.8-unit corridor: 55 / 101 sampled rigid-tail frames collide.", 14))
    a.add_child(_font("First passing width in tested grid: 4.6 normalized units.", 13, PAPER))
    a.add_child(_font("Assumed lateral COM transfer: 0.205 normalized units.", 13, ACCENT))
    a.add_child(_font("Anatomical scale, true gait and grip: unvalidated.", 13, GOLD))

    var b: VBoxContainer = _panel(855, 405, "H-B    /    COMPACT TAIL", ACCENT)
    b.add_child(_font("T10 fixed 2.8-unit corridor: 0 / 101 collisions in model.", 14))
    b.add_child(_font("First passing width in tested grid: 2.8 normalized units.", 13, PAPER))
    b.add_child(_font("Assumed lateral COM transfer: 0.265 normalized units.", 13, ACCENT))
    b.add_child(_font("Wrist mechanics, material load, real stability: unvalidated.", 13, GOLD))

    var middle := PanelContainer.new()
    middle.position = Vector2(424, 478)
    middle.custom_minimum_size = Vector2(410, 205)
    var mid_style := StyleBoxFlat.new()
    mid_style.bg_color = Color(0.10, 0.16, 0.18, 0.95)
    mid_style.border_color = Color(0.73, 0.57, 0.35)
    mid_style.set_border_width_all(1)
    mid_style.set_content_margin_all(14)
    middle.add_theme_stylebox_override("panel", mid_style)
    layer.add_child(middle)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 8)
    middle.add_child(stack)
    stack.add_child(_font("DECISION STATUS", 19, GOLD))
    status = _font("", 14, PAPER)
    stack.add_child(status)
    stack.add_child(_font("H-C hybrid: not constructed or tested. No inferred metrics.", 13, ACCENT))
    footer = _font("", 12, GOLD)
    stack.add_child(footer)


func _refresh_review() -> void:
    if status != null:
        status.text = "NO SPECIES MORPHOLOGY APPROVED. T14 scientific and creator gates remain open."
    if footer != null:
        footer.text = "NO METERS, MUSCLE FORCES OR CANON DECISION • %s" % selected_review
    if info != null:
        info.text = "0 paired / 1 long tail / 2 compact tail     •     models are not measured"


func set_review_focus(focus: String) -> bool:
    if focus not in ["both", "H-A", "H-B"]:
        return false
    selected_review = focus
    if not set_display_mode(focus):
        return false
    _refresh_review()
    return true


func record_creator_approval(_choice: String) -> bool:
    # An agent, screenshot, user keypress or model score cannot approve canon.
    # Creator's explicit written decision must be recorded under a separate,
    # independently validated approved revision, not guessed by this scene.
    return false


func review_summary() -> Dictionary:
    var rows: Array = review.get("comparisons", [])
    var gates: Array = review.get("gates", [])
    return {
        "status":review.get("status",""),
        "hypotheses":rows.size(),
        "scientific_gate_count":gates.size(),
        "creator_approval_recorded":review.get("current_decision",null) != null,
        "comparative_meshes":skins.size(),
        "selected":selected_review,
        "modern_species_claim":review.get("present_day_body_specified",true),
        "model_scientifically_calibrated":false,
        "hybrid_built":false,
        "can_auto_approve":false
    }


func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode == KEY_0:
        set_review_focus("both")
    elif event.keycode == KEY_1:
        set_review_focus("H-A")
    elif event.keycode == KEY_2:
        set_review_focus("H-B")
    else:
        super._unhandled_key_input(event)
