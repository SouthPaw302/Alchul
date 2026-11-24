extends "res://scripts/surface_zenith_fidelity_assets.gd"
## Two 2K hero material families, other families retain original 512 maps.
const HERO_SIZE: int = 2048
func _surface_maps(family: String) -> Dictionary:
    if maps.has(family):
        return maps[family]
    if not family in ["skin","plumage"]:
        return super._surface_maps(family)
    var c := Image.create(HERO_SIZE,HERO_SIZE,false,Image.FORMAT_RGB8)
    var n := Image.create(HERO_SIZE,HERO_SIZE,false,Image.FORMAT_RGB8)
    var rough := Image.create(HERO_SIZE,HERO_SIZE,false,Image.FORMAT_RGB8)
    for y in range(HERO_SIZE):
        for x in range(HERO_SIZE):
            var u: float = float(x)/HERO_SIZE
            var v: float = float(y)/HERO_SIZE
            var micro: float = sin(TAU*(u*231.0+v*187.0))*sin(TAU*(v*197.0-u*113.0))
            var a: float
            var dx: float
            var dy: float
            if family=="skin":
                var row: float = floor(v*64.0)
                var xx: float = fposmod(u*76.0+fmod(row,2.0)*0.5,1.0)-0.5
                var yy: float = fposmod(v*64.0,1.0)-0.5
                var f: float = 1.0-smoothstep(0.24,0.48,Vector2(xx,yy).length())
                a = 0.68+0.22*f+0.045*micro
                dx = xx*f*0.62+micro*0.025
                dy = yy*f*0.62
            else:
                var barb: float = TAU*(u*130.0+absf(v-0.5)*18.0+sin(v*TAU*5.0)*0.14)
                var shaft: float = exp(-pow((u-0.5)*160.0,2.0))
                a = 0.77+0.10*sin(barb)+0.07*shaft+0.035*micro
                dx = cos(barb)*0.19
                dy = sin(barb)*0.10
            var normal: Vector3 = Vector3(dx,dy,1.0).normalized()
            c.set_pixel(x,y,Color(a,a,a))
            n.set_pixel(x,y,Color(normal.x*0.5+0.5,normal.y*0.5+0.5,normal.z*0.5+0.5))
            var rv: float = 0.70+0.17*(1.0-a)+0.04*micro
            rough.set_pixel(x,y,Color(rv,rv,rv))
    c.generate_mipmaps()
    n.generate_mipmaps()
    rough.generate_mipmaps()
    maps[family] = {"albedo":ImageTexture.create_from_image(c),"normal":ImageTexture.create_from_image(n),"roughness":ImageTexture.create_from_image(rough),"albedo_image":c,"normal_image":n,"roughness_image":rough}
    return maps[family]

func material(tint: Color, rough: float = 0.84) -> StandardMaterial3D:
    var m: StandardMaterial3D = super.material(tint,rough)
    var family: String = _family(tint)
    if m.albedo_texture != null and family in ["skin","plumage"]:
        m.roughness_texture = _surface_maps(family)["roughness"]
    return m

func export_maps(dir: String) -> bool:
    if not super.export_maps(dir):
        return false
    for family in ["skin","plumage"]:
        if _surface_maps(family)["roughness_image"].save_png(dir.path_join(family+"_roughness.png")) != OK:
            return false
    return true
