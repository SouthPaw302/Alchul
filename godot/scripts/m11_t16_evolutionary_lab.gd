extends "res://scripts/m11_t13_skinned_character_lab.gd"

## Three separately parameterized hypothetical evolutionary trajectories.
## Bone topology inherited from phylogenetically constrained T07 arthitecture.
## Delta manipulation is a transparent morphometric model, not empirical
## ancestral-state reconstruction. Does NOT establish real anatomy/canon.
const PROFILE_PATH: String = "res://data/m11_t16_evolutionary_profiles.json"
const SCIENCE_STATUS: String = "UNVALIDATED_EVOLUTIONARY_TRAJECTORY_HYPOTHESES_NOT_CANON"
const PALETTE: Dictionary = {
    "E1": Color(0.45, 0.47, 0.34),
    "E2": Color(0.33, 0.46, 0.44),
    "E3": Color(0.55, 0.44, 0.34)
}
var evolutionary_profiles: Dictionary = {}
var evolved_specs: Dictionary = {}
var evolutionary_metric_proxies: Dictionary = {}
var active_integument: float = 1.0
var evolutionary_only: bool = false


func _ready() -> void:
    super._ready()
    var decoded: Variant = JSON.parse_string(FileAccess.get_file_as_string(PROFILE_PATH))
    if not (decoded is Dictionary) or decoded.get("status","") != SCIENCE_STATUS:
        push_error("T16 evolutionary profile incorrectly approved or unavailable")
        return
    evolutionary_profiles = decoded
    if registry.get("bodies", []).size() != 2:
        push_error("T16 evolutionary model missing comparative ancestral hypotheses")
        return
    var order: int = 0
    for profile in evolutionary_profiles.get("selection_contexts", []):
        var spec: Dictionary = _derive_morphometric_spec(profile)
        var key: String = spec["id"]
        if spec.get("bones", []).size() != 43 or not key in ["E1","E2","E3"]:
            push_error("T16 invalid evolved design graph")
            return
        evolved_specs[key] = spec
        _create_skeleton(spec, 2)
        (rigs[key]["root"] as Node3D).position = Vector3(-5.5 + float(order) * 5.5, 0, 0)
        active_integument = float(profile["params"]["integument_volume"])
        _create_character_shell(spec)
        _create_soft_tissue_visuals(key, profile)
        evolutionary_metric_proxies[key] = _proxy_report(spec, profile)
        var visual_label: Label3D = (rigs[key]["root"] as Node3D).get_node("HypothesisLabel")
        visual_label.text = key + " | RESEARCH HYPOTHESIS, NOT SPECIES"
        visual_label.position = Vector3(-1.65, 3.65, 0)
        order += 1
    active_integument = 1.0
    (rigs["H-A"]["root"] as Node3D).visible = false
    (rigs["H-B"]["root"] as Node3D).visible = false
    evolutionary_only = true
    var cam: Camera3D = get_node("MatchedT07Camera")
    cam.position = Vector3(0, 4.4, 22.0)
    cam.fov = 57.0
    cam.look_at(Vector3(0, 1.6, 0))
    set_clip("rest")
    set_surface_variant("river_silt")
    _update_evolved_header()
    print("ALCHUL T16 THREE INDEPENDENT EVOLUTIONARY HYPOTHESIS 43-CONTROL MODELS GENERATED")


func _derive_morphometric_spec(profile: Dictionary) -> Dictionary:
    var first: Dictionary = registry["bodies"][0]
    var second: Dictionary = registry["bodies"][1]
    var reference_a: Dictionary = {}
    var reference_b: Dictionary = {}
    for row in first["bones"]:
        reference_a[row["name"]] = row
    for row in second["bones"]:
        reference_b[row["name"]] = row
    var mixture: float = float(profile["morph_source_mix"])
    var parameters: Dictionary = profile["params"]
    var targets: Dictionary = {}
    var records: Array = []
    for old in first["bones"]:
        var name: String = str(old["name"])
        var region: String = str(old["region"])
        var parent_value: Variant = old.get("parent", null)
        var a: Array = reference_a[name]["anchor"]
        var b: Array = reference_b[name]["anchor"]
        var value: Vector3
        if parent_value == null:
            value = Vector3(float(a[0]),float(a[1]),float(a[2])).lerp(
                Vector3(float(b[0]),float(b[1]),float(b[2])),mixture)
        else:
            var parent_name: String = str(parent_value)
            var ap: Array = reference_a[parent_name]["anchor"]
            var bp: Array = reference_b[parent_name]["anchor"]
            var local_a := Vector3(float(a[0])-float(ap[0]),float(a[1])-float(ap[1]),float(a[2])-float(ap[2]))
            var local_b := Vector3(float(b[0])-float(bp[0]),float(b[1])-float(bp[1]),float(b[2])-float(bp[2]))
            var displacement: Vector3 = local_a.lerp(local_b,mixture)
            if name.begins_with("caudal_") or region == "caudal":
                displacement.x *= float(parameters["tail_scale"])
            if name in ["spine","thorax"]:
                displacement.x *= float(parameters["thorax_reach"])
            if name.begins_with("neck_"):
                displacement.y *= float(parameters["neck_height"])
            if region in ["forelimb","manual"]:
                displacement.x *= float(parameters["forelimb_reach"])
            if region == "hindlimb":
                displacement.y *= float(parameters["hindlimb_height"])
            if region == "pedal":
                displacement.z *= float(parameters["pedal_spread"])
            if region == "cranial":
                displacement.x *= float(parameters["cranial_length"])
            value = (targets[parent_name] as Vector3) + displacement
        targets[name] = value
        records.append({"name":name,"parent":parent_value,
            "anchor":[snappedf(value.x,0.000001),snappedf(value.y,0.000001),snappedf(value.z,0.000001)],
            "region":region})
    return {"id":profile["id"],"label":profile["label"],"bones":records,
        "status":"MORPHOMETRIC_SCENARIO_NOT_MEASURED"}


func _radius(name: String) -> float:
    var original: float = super._radius(name)
    if name.begins_with("pedal_") or name.begins_with("manual_"):
        return original
    return original * active_integument


func _create_soft_tissue_visuals(key: String, profile: Dictionary) -> void:
    # Minimal parametric surface-volume priors: NOT muscle or fossil soft tissue.
    # BoneAttachment3D causes every module to follow its real 43-bone skeleton.
    var skeleton: Skeleton3D = rigs[key]["skeleton"]
    var params: Dictionary = profile["params"]
    var base: Color = PALETTE[key]
    var tissue := StandardMaterial3D.new()
    tissue.albedo_color = base
    tissue.roughness = 0.92
    var mantle := StandardMaterial3D.new()
    mantle.albedo_color = base.darkened(0.14)
    mantle.roughness = 0.95
    var soft_nodes: Array = [
        {"bone":"pelvis","scale":Vector3(0.48,0.30,0.38),"offset":Vector3(0.12,-0.11,0)},
        {"bone":"thorax","scale":Vector3(0.59,0.36,0.34),"offset":Vector3(-0.15,-0.03,0)},
        {"bone":"skull","scale":Vector3(0.29,0.22,0.22),"offset":Vector3(0.055,0.02,0)},
        {"bone":"caudal_01","scale":Vector3(0.37,0.15,0.16),"offset":Vector3(0.10,0.02,0)},
        {"bone":"neck_01","scale":Vector3(0.19,0.20,0.18),"offset":Vector3(-0.07,0,0)}
    ]
    for item in soft_nodes:
        var attachment := BoneAttachment3D.new()
        attachment.name = "ResearchSoftVolume_" + item["bone"]
        attachment.bone_name = item["bone"]
        skeleton.add_child(attachment)
        var volume := MeshInstance3D.new()
        volume.name = "InferredNotCalibratedVolume"
        var mesh := SphereMesh.new()
        mesh.radius = 1.0
        mesh.height = 2.0
        mesh.radial_segments = 16
        mesh.rings = 10
        volume.mesh = mesh
        var scale_var: Vector3 = item["scale"]
        if item["bone"] == "thorax":
            scale_var *= Vector3(float(params["thorax_reach"]),
                float(params["integument_volume"]),1.0)
        if item["bone"] == "caudal_01":
            scale_var.x *= float(params["tail_scale"])
        volume.scale = scale_var
        volume.position = item["offset"]
        volume.material_override = mantle if str(item["bone"]).begins_with("caudal_") else tissue
        attachment.add_child(volume)


func _proxy_report(spec: Dictionary, profile: Dictionary) -> Dictionary:
    var rows: Array = spec["bones"]
    var positions: Dictionary = {}
    for record in rows:
        var xyz: Array = record["anchor"]
        positions[record["name"]] = Vector3(float(xyz[0]),float(xyz[1]),float(xyz[2]))
    var left: float = INF
    var right: float = -INF
    var top: float = -INF
    var bottom: float = INF
    for point in positions.values():
        var v: Vector3 = point
        left = minf(left,v.x)
        right = maxf(right,v.x)
        bottom = minf(bottom,v.y)
        top = maxf(top,v.y)
    return {"id":profile["id"],"axis_extent_normalized":right-left,
        "height_normalized":top-bottom,
        "caudal_tip_x":(positions["caudal_04"] as Vector3).x,
        "pedal_lateral_width_proxy":absf((positions["pedal_III_L"] as Vector3).z-
            (positions["pedal_III_R"] as Vector3).z),
        "physical_metres":false,"fossil_measurements":false,
        "selection_coefficient_estimated":false}


func set_evolutionary_focus(id: String) -> bool:
    if not id in ["all","E1","E2","E3"] or not evolutionary_only:
        return false
    for key in ["E1","E2","E3"]:
        (rigs[key]["root"] as Node3D).visible = id == "all" or key == id
    for key in ["H-A","H-B"]:
        (rigs[key]["root"] as Node3D).visible = false
    return true


func _update_evolved_header() -> void:
    var canvas: CanvasLayer = get_node("SkeletalStudyHud")
    canvas.visible = false
    var overlay := CanvasLayer.new()
    overlay.name = "EvolutionaryMorphologyBanner"
    add_child(overlay)
    var heading := Label.new()
    heading.text = "ALCHUL / T16 EVOLUTIONARY RECONSTRUCTION • THREE UNAPPROVED HYPOTHESES"
    heading.position = Vector2(20,18)
    heading.add_theme_font_size_override("font_size",20)
    heading.add_theme_color_override("font_color",Color(0.11,0.20,0.20))
    overlay.add_child(heading)
    var sub := Label.new()
    sub.text = "E1 RIVERBANK  /  E2 MATERIALS  /  E3 NURSERY   •   43-BONE RIGS   •   NOT FOSSIL SPECIES   •   NO PHYSICAL METRES"
    sub.position = Vector2(20,49)
    sub.add_theme_font_size_override("font_size",14)
    sub.add_theme_color_override("font_color",Color(0.12,0.25,0.25))
    overlay.add_child(sub)


func model_summary() -> Dictionary:
    var output: Dictionary = {}
    for key in ["E1","E2","E3"]:
        var sk: Skeleton3D = rigs[key]["skeleton"]
        var mesh: MeshInstance3D = (rigs[key]["root"] as Node3D).get_node("SkinnedShell_LOD0")
        output[key] = {"bone_count":sk.get_bone_count(),"skinned":mesh.skin!=null,
            "material_surfaces":mesh.mesh.get_surface_count(),
            "proxy_geometry":evolutionary_metric_proxies[key]}
    return {"status":SCIENCE_STATUS,"candidate_count":3,"models":output,
        "source":"T07 43-control topology plus T16 explicit selection context",
        "is_evolutionary_prediction":false,"selection_coefficients_known":false,
        "biological_approved":false,"creator_approved":false,
        "present_day_morphology_known":false,
        "soft_tissue_bone_attachment_visual_only":true}


func _unhandled_key_input(event: InputEvent) -> void:
    if not(event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_0:
            set_evolutionary_focus("all")
        KEY_1:
            set_evolutionary_focus("E1")
        KEY_2:
            set_evolutionary_focus("E2")
        KEY_3:
            set_evolutionary_focus("E3")
        KEY_SPACE:
            playing = not playing
        _:
            return
