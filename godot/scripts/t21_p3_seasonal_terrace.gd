extends "res://scripts/t21_p2_living_terrace.gd"

const Calendar = preload("res://scripts/t21_p3_seasonal_calendar.gd")
var calendar = Calendar.new()
var ledger_shelf: Node3D
var ledger_stones: Array[MeshInstance3D] = []
var ledger_caption: Label3D

func _ready() -> void:
    super._ready()
    ledger_shelf = Node3D.new()
    ledger_shelf.name = "SharedSeasonRecord_NotAnatomy"
    terrace.add_child(ledger_shelf)
    _box(ledger_shelf, "RecordShelf", Vector3(0,0.22,3.12), Vector3(5.0,0.24,0.62), ROOT)
    for i in range(8):
        var token: MeshInstance3D = _box(ledger_shelf, "Day_%02d" % (i+1),
            Vector3(-2.1+float(i)*0.60,0.40,3.12), Vector3(0.43,0.12,0.40), CLAY)
        ledger_stones.append(token)
    ledger_caption = _inscription(ledger_shelf, "SHARED SEASON RECORD",
        Vector3(0,0.92,3.12), PALE)
    _update_hud()

func start_calendar() -> bool:
    if calendar.day != 0 or not calendar.begin(snapshot()):
        return false
    _update_hud()
    return true

func assign_duty(duty: String) -> bool:
    if not calendar.choose(duty):
        return false
    _update_hud()
    return true

func reset_day() -> void:
    calendar = Calendar.new()
    super.reset_day()

func _update_hud() -> void:
    super._update_hud()
    if title_text == null or config.is_empty():
        return
    title_text.text = "ALCHUL / T21.3 — THE SEASON RECORD | WATCH %d / 8" % turn
    if calendar.day == 0:
        if concluded and _all_systems_safe():
            event_text.text = "The first day holds. N opens the seasonal ledger; R restarts the study."
        if ledger_caption != null:
            ledger_caption.text = "SHARED SEASON RECORD / NOT STARTED"
    else:
        var report: Dictionary = calendar.report()
        var stocks: Dictionary = report["resources"]
        title_text.text = "ALCHUL / T21.3 — DAY %d / 8 | %s" % [calendar.day, report["phase"]]
        meter_text.text = "FOOD %d | CARE %d | REPAIR %d | MATERIAL %d | REST %d | LEARNING %d" % [
            stocks["food"], stocks["care"], stocks["repair"], stocks["materials"], stocks["rest"], stocks["knowledge"]]
        action_text.text = "1 Provision | 2 Care | 3 Maintain | 4 Teach | 5 Replenish | 6 Rest | R Restart"
        var duty_text: String = ", ".join(PackedStringArray(calendar.chosen))
        event_text.text = "Choose two different duties per day. Selected: %s | unmet needs: %d" % [duty_text, calendar.deficits]
        if calendar.finished:
            event_text.text = "SEASON RECORD COMPLETE — " + ("continuity held" if report["continuity"] else "unmet duties or learning; review the record") + " | R Restart"
        provenance_text.text = "Compressed fictional calendar; terrace holds the previous protected-day geometry. No calibrated ecology or approved bodies."
        if ledger_caption != null:
            ledger_caption.text = "SHARED RECORD / %s" % report["phase"]
    for i in range(ledger_stones.size()):
        var tint: Color = CLAY
        if i < calendar.ledger.size():
            tint = REED if calendar.ledger[i]["unmet_needs"].is_empty() else WARM
        elif calendar.day == i+1 and not calendar.finished:
            tint = PALE
        ledger_stones[i].material_override = _surface(tint)

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode == KEY_N:
        start_calendar()
    elif calendar.day == 0 or event.keycode == KEY_R:
        super._unhandled_key_input(event)
    elif event.keycode >= KEY_1 and event.keycode <= KEY_6:
        assign_duty(Calendar.DUTIES[int(event.keycode)-int(KEY_1)])
