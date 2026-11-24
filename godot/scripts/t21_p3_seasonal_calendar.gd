extends RefCounted
## A compressed eight-day fictional calendar. All counts are narrative units.
const PHASES: Array[String] = ["Rising water", "Warm growth", "Lean water", "Cool return"]
const DUTIES: Array[String] = ["provision", "care", "maintain", "teach", "replenish", "rest"]
const MAX_DAYS: int = 8
var day: int = 0
var resources: Dictionary = {}
var chosen: Array[String] = []
var ledger: Array[Dictionary] = []
var deficits: int = 0
var finished: bool = false
var opening_record: Dictionary = {}

func begin(previous: Dictionary) -> bool:
    if not previous.get("concluded", false) or not previous.get("all_systems_safe", false):
        return false
    var s: Dictionary = previous.get("state", {})
    opening_record = previous.duplicate(true)
    resources = {"food": clampi(roundi(float(s.get("food", 0)) / 10.0), 1, 10),
        "care": clampi(roundi(float(s.get("nursery", 0)) / 12.0), 1, 10),
        "repair": clampi(roundi(float(s.get("integrity", 0)) / 12.0), 1, 10),
        "materials": clampi(int(s.get("materials", 0)), 0, 10),
        "rest": 5, "knowledge": 0}
    day = 1
    chosen.clear()
    ledger.clear()
    deficits = 0
    finished = false
    return true

func phase_index() -> int:
    return clampi(int((day - 1) / 2.0), 0, PHASES.size() - 1)

func _adjust(key: String, change: int) -> void:
    resources[key] = clampi(int(resources[key]) + change, 0, 12)

func choose(duty: String) -> bool:
    if day == 0 or finished or not duty in DUTIES or duty in chosen:
        return false
    if duty == "maintain" and int(resources["materials"]) == 0:
        return false
    match duty:
        "provision": _adjust("food", 4)
        "care": _adjust("care", 4)
        "maintain":
            _adjust("materials", -1)
            _adjust("repair", 4)
        "teach": _adjust("knowledge", 1)
        "replenish": _adjust("materials", 3)
        "rest": _adjust("rest", 4)
    chosen.append(duty)
    if chosen.size() == 2:
        _close_day()
    return true

func _close_day() -> void:
    var phase: int = phase_index()
    var costs: Dictionary = {"food": 1, "care": 1, "rest": 1, "repair": 0}
    match phase:
        0: costs["repair"] = 1
        1: costs["care"] = 2
        2: costs["food"] = 2
        3: costs["care"] = 2
    var missed: Array[String] = []
    for key in costs:
        var cost: int = int(costs[key])
        if int(resources[key]) < cost:
            missed.append(str(key))
        _adjust(str(key), -cost)
    deficits += missed.size()
    ledger.append({"day": day, "phase": PHASES[phase], "duties": chosen.duplicate(),
        "unmet_needs": missed, "resources": resources.duplicate(true)})
    chosen.clear()
    if day == MAX_DAYS:
        finished = true
    else:
        day += 1

func report() -> Dictionary:
    return {"day": day, "phase": PHASES[phase_index()] if day > 0 else "Not started",
        "resources": resources.duplicate(true), "chosen": chosen.duplicate(),
        "ledger": ledger.duplicate(true), "deficits": deficits, "finished": finished,
        "continuity": finished and deficits == 0 and int(resources.get("knowledge", 0)) >= 2,
        "opening_record": opening_record.duplicate(true),
        "calendar_is_compressed": true, "approved_anatomy": false}
